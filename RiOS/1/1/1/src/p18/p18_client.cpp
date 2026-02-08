#include <iostream>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <cstring>
#include <chrono>
#include <thread>
#include <csignal>
#include "get_sync.h"
#include "set_sync.h"

using namespace std;

int sockfd = -1;
sockaddr_in serverAddr{};
chrono::steady_clock::time_point startTime;
int currentTime = 0;
int requestCount = 0;
bool running = true;

int getElapsedTime() {
    auto now = chrono::steady_clock::now();
    return chrono::duration_cast<chrono::milliseconds>(now - startTime).count();
}

bool sendSyncRequest() {
    GetSync request{};
    strncpy(request.cmd, "GET", 3);
    request.currentValue = currentTime;

    ssize_t sent = sendto(sockfd, &request, sizeof(request), 0,
                          (struct sockaddr *) &serverAddr, sizeof(serverAddr));
    return sent == sizeof(request);
}

bool receiveCorrection() {
    SetSync response{};
    ssize_t received = recv(sockfd, &response, sizeof(response), 0);

    if (received != sizeof(response) || strncmp(response.cmd, "SYNC", 4) != 0) {
        return false;
    }

    int correction = response.correction;

    cout << "Request #" << requestCount;
    cout << " - Applied correction: " << correction;

    currentTime += correction;

    cout << " - New time: " << currentTime << endl;

    return true;
}

void sendDisconnect() {
    GetSync request{};
    strncpy(request.cmd, "DISC", 4);
    request.currentValue = currentTime;
    sendto(sockfd, &request, sizeof(request), 0,
           (struct sockaddr *) &serverAddr, sizeof(serverAddr));
}

bool initialize(const char *serverIP) {
    startTime = chrono::steady_clock::now();

    sockfd = socket(AF_INET, SOCK_DGRAM, 0);
    if (sockfd < 0) {
        cerr << "Socket creation failed" << endl;
        return false;
    }

    struct timeval timeout{2, 0}; // 2 seconds
    setsockopt(sockfd, SOL_SOCKET, SO_RCVTIMEO, &timeout, sizeof(timeout));

    memset(&serverAddr, 0, sizeof(serverAddr));
    serverAddr.sin_family = AF_INET;
    serverAddr.sin_port = htons(8080);
    inet_pton(AF_INET, serverIP, &serverAddr.sin_addr);

    cout << "Time sync client initialized" << endl;
    return true;
}

void run(int syncPeriodMs) {
    while (running) {
        int baseTime = getElapsedTime();
        if (requestCount == 0) {
            currentTime = baseTime;
        }

        requestCount++;

        if (sendSyncRequest()) {
            if (!receiveCorrection()) {
                cerr << "Failed to receive correction for request #" << requestCount << endl;
            }
        } else {
            cerr << "Failed to send sync request #" << requestCount << endl;
        }

        this_thread::sleep_for(chrono::milliseconds(syncPeriodMs));
        currentTime += syncPeriodMs;
    }

    sendDisconnect();
    cout << "Client disconnected after " << requestCount << " requests" << endl;
}

void stop() { running = false; }

void signalHandler(int sig) {
    cout << "\nShutting down..." << endl;
    stop();
}

void cleanup() {
    if (sockfd >= 0) {
        close(sockfd);
    }
}

int main(int argc, char *argv[]) {
    if (argc != 3) {
        cout << "Usage: " << argv[0] << " <server_IP> <sync_period_ms>" << endl;
        return -1;
    }

    const char *serverIP = argv[1];
    int syncPeriod = atoi(argv[2]);

    if (syncPeriod <= 0) {
        cerr << "Sync period must be positive" << endl;
        return -1;
    }

    signal(SIGINT, signalHandler);
    signal(SIGTERM, signalHandler);

    if (!initialize(serverIP)) {
        return -1;
    }

    cout << "Starting sync with period " << syncPeriod << "ms. Press Ctrl+C to stop." << endl;
    run(syncPeriod);

    cleanup();
    return 0;
}
