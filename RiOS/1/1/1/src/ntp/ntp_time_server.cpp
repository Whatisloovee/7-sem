#include <iostream>
#include <thread>
#include <chrono>
#include <cstring>
#include <csignal>
#include <arpa/inet.h>
#include <unistd.h>
#include <atomic>
#include <netdb.h>
#include <vector>
#include <cmath>
#include <sys/socket.h>
#include <netinet/in.h>
#include <algorithm>

using namespace std;

atomic<bool> running(true);
int sockfd = -1;
atomic<uint64_t> Cs(0);
atomic<int64_t> totalCorrection(0);
atomic<int> syncCount(0);

void cleanup() {
    running = false;
    if (sockfd >= 0) {
        close(sockfd);
        cout << "\n[SERVER] Socket closed, server stopped." << endl;
    }
}

uint64_t getCurrentTimeMs() {
    auto now = chrono::system_clock::now();
    return chrono::duration_cast<chrono::milliseconds>(now.time_since_epoch()).count();
}

uint64_t getNtpTime(const char *ntpServer = "pool.ntp.org") {
    cout << "[NTP] Connecting to " << ntpServer << "..." << endl;

    struct hostent *he = gethostbyname(ntpServer);
    if (he == nullptr) {
        throw runtime_error("Cannot resolve NTP server hostname");
    }

    int fd = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
    if (fd < 0) {
        throw runtime_error("NTP socket creation failed");
    }

    struct timeval timeout;
    timeout.tv_sec = 5;
    timeout.tv_usec = 0;
    setsockopt(fd, SOL_SOCKET, SO_RCVTIMEO, &timeout, sizeof(timeout));

    sockaddr_in addr{};
    addr.sin_family = AF_INET;
    addr.sin_port = htons(123);
    memcpy(&addr.sin_addr, he->h_addr, he->h_length);

    uint8_t packet[48]{};
    packet[0] = 0x1B; // LI=0, VN=3, Mode=3

    if (sendto(fd, packet, sizeof(packet), 0, (sockaddr *) &addr, sizeof(addr)) < 0) {
        close(fd);
        throw runtime_error("NTP send failed");
    }

    sockaddr_in recvAddr{};
    socklen_t addrLen = sizeof(recvAddr);
    ssize_t received = recvfrom(fd, packet, sizeof(packet), 0,
                                (sockaddr *) &recvAddr, &addrLen);

    if (received < 48) {
        close(fd);
        throw runtime_error("Invalid NTP response");
    }

    close(fd);

    uint32_t secs, fraction;
    memcpy(&secs, &packet[40], 4);
    memcpy(&fraction, &packet[44], 4);
    secs = ntohl(secs);
    fraction = ntohl(fraction);

    const uint32_t ntpToUnix = 2208988800UL;
    uint64_t unixTimeSec = (uint64_t) (secs - ntpToUnix);
    uint64_t fractionMs = (uint64_t) (fraction / 4294967.295);

    return unixTimeSec * 1000ULL + fractionMs;
}

void syncWithGlobal() {
    const vector<const char *> ntpServers = {
            "pool.ntp.org",
            "time.google.com",
            "time.cloudflare.com",
            "0.pool.ntp.org",
            "1.pool.ntp.org"
    };

    vector<int64_t> corrections;
    int currentServer = 0;
    uint64_t lastSystemTime = getCurrentTimeMs();

    while (running) {
        try {
            uint64_t ntpTime = getNtpTime(ntpServers[currentServer]);
            uint64_t systemTime = getCurrentTimeMs();

            int64_t correction = ntpTime - systemTime;
            corrections.push_back(correction);

            if (corrections.size() >= 3) {
                vector<int64_t> sorted = corrections;
                sort(sorted.begin(), sorted.end());
                int64_t medianCorrection = sorted[sorted.size() / 2];

                Cs = systemTime + medianCorrection;
                totalCorrection += medianCorrection;
            } else {
                Cs = ntpTime;
            }

            syncCount++;
            cout << "[SYNC #" << syncCount << "] Cs = " << Cs
                 << " | Correction: " << correction << " ms"
                 << " | Server: " << ntpServers[currentServer] << endl;

            currentServer = 0;

        } catch (const exception &e) {
            cerr << "[ERROR] " << ntpServers[currentServer] << ": " << e.what() << endl;
            currentServer = (currentServer + 1) % ntpServers.size();

            Cs = getCurrentTimeMs();
        }

        for (int i = 0; i < 100 && running; i++) {
            this_thread::sleep_for(chrono::milliseconds(100));
        }
    }
}

void signalHandler(int sig) {
    cleanup();
    exit(0);
}

int main() {
    signal(SIGINT, signalHandler);
    signal(SIGTERM, signalHandler);

    sockfd = socket(AF_INET, SOCK_DGRAM, 0);
    if (sockfd < 0) {
        cerr << "[ERROR] Socket creation failed" << endl;
        return -1;
    }

    sockaddr_in serverAddr{};
    serverAddr.sin_family = AF_INET;
    serverAddr.sin_port = htons(8080);
    serverAddr.sin_addr.s_addr = INADDR_ANY;

    if (bind(sockfd, (sockaddr *) &serverAddr, sizeof(serverAddr)) < 0) {
        cerr << "[ERROR] Bind failed" << endl;
        close(sockfd);
        return -1;
    }

    cout << "[SERVER] Time sync server started on port 8080" << endl;
    cout << "[SERVER] Synchronizing with global NTP servers every 10 seconds" << endl;

    thread syncThread(syncWithGlobal);
    syncThread.detach();

    sockaddr_in clientAddr{};
    socklen_t clientLen = sizeof(clientAddr);
    char buffer[64];

    while (running) {
        ssize_t n = recvfrom(sockfd, buffer, sizeof(buffer) - 1, 0,
                             (sockaddr *) &clientAddr, &clientLen);
        if (n <= 0) continue;

        buffer[n] = '\0';

        if (strncmp(buffer, "GET", 3) == 0) {
            uint64_t currentTime = Cs.load();
            uint64_t networkTime = htobe64(currentTime);

            sendto(sockfd, &networkTime, sizeof(networkTime), 0,
                   (sockaddr *) &clientAddr, clientLen);

            cout << "[CLIENT] " << inet_ntoa(clientAddr.sin_addr) << ":"
                 << ntohs(clientAddr.sin_port) << " -> " << currentTime << " ms" << endl;
        }
    }

    cleanup();
    return 0;
}