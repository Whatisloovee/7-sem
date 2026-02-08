#include <iostream>
#include <arpa/inet.h>
#include <unistd.h>
#include <cstring>
#include <thread>
#include <chrono>
#include <csignal>
#include <vector>
#include <cmath>
#include <sys/socket.h>
#include <netinet/in.h>
#include <algorithm>

using namespace std;

bool running = true;
int sockfd = -1;
sockaddr_in serverAddr{};
uint64_t OStime = 0;
uint64_t Cc = 0;

void cleanup() {
    running = false;
    if (sockfd >= 0) close(sockfd);
    cout << "\n[CLIENT] Cleanup complete." << endl;
}

void signalHandler(int sig) {
    cleanup();
    exit(0);
}

uint64_t getCurrentTimeMs() {
    return chrono::duration_cast<chrono::milliseconds>(
            chrono::system_clock::now().time_since_epoch()).count();
}

uint64_t getServerTime() {
    const char *request = "GET";

    if (sendto(sockfd, request, strlen(request), 0,
               (sockaddr *) &serverAddr, sizeof(serverAddr)) < 0) {
        throw runtime_error("Send failed");
    }

    uint64_t serverTime;
    sockaddr_in fromAddr;
    socklen_t fromLen = sizeof(fromAddr);

    ssize_t n = recvfrom(sockfd, &serverTime, sizeof(serverTime), 0,
                         (sockaddr *) &fromAddr, &fromLen);

    if (n != sizeof(serverTime)) {
        throw runtime_error("Invalid response");
    }

    return be64toh(serverTime);
}

void applyTimeCorrection(int64_t correction) {
    cout << "[OS TIME] Would apply correction: " << correction << " ms" << endl;
    OStime = getCurrentTimeMs() + correction;
    Cc = OStime;
}

void printStats(const vector<int64_t> &corrections, const vector<int64_t> &timeDiffs) {
    if (corrections.empty() || timeDiffs.empty()) return;

    int64_t sumCorr = 0;
    int64_t minCorr = corrections[0], maxCorr = corrections[0];

    for (auto corr: corrections) {
        sumCorr += corr;
        if (corr < minCorr) minCorr = corr;
        if (corr > maxCorr) maxCorr = corr;
    }
    double avgCorr = static_cast<double>(sumCorr) / corrections.size();

    int64_t sumDiff = 0;
    int64_t minDiff = timeDiffs[0], maxDiff = timeDiffs[0];

    for (auto diff: timeDiffs) {
        sumDiff += diff;
        if (diff < minDiff) minDiff = diff;
        if (diff > maxDiff) maxDiff = diff;
    }
    double avgDiff = static_cast<double>(sumDiff) / timeDiffs.size();

    double varianceCorr = 0;
    for (auto corr: corrections) {
        varianceCorr += pow(corr - avgCorr, 2);
    }
    double stddevCorr = sqrt(varianceCorr / corrections.size());

    double varianceDiff = 0;
    for (auto diff: timeDiffs) {
        varianceDiff += pow(diff - avgDiff, 2);
    }
    double stddevDiff = sqrt(varianceDiff / timeDiffs.size());

    cout << "========================================" << endl;
    cout << "[STATS] Samples: " << corrections.size() << endl;
    cout << "----------------------------------------" << endl;
    cout << "CORRECTION STATISTICS:" << endl;
    cout << "  Average correction: " << avgCorr << " ms" << endl;
    cout << "  Min correction: " << minCorr << " ms" << endl;
    cout << "  Max correction: " << maxCorr << " ms" << endl;
    cout << "  StdDev correction: " << stddevCorr << " ms" << endl;
    cout << "----------------------------------------" << endl;
    cout << "TIME DIFFERENCE STATISTICS (Cc - OStime):" << endl;
    cout << "  Average difference: " << avgDiff << " ms" << endl;
    cout << "  Min difference: " << minDiff << " ms" << endl;
    cout << "  Max difference: " << maxDiff << " ms" << endl;
    cout << "  StdDev difference: " << stddevDiff << " ms" << endl;
    cout << "========================================" << endl;
}

int main(int argc, char *argv[]) {
    if (argc != 3) {
        cerr << "Usage: " << argv[0] << " <server_ip> <sync_period_ms>" << endl;
        return -1;
    }

    signal(SIGINT, signalHandler);
    signal(SIGTERM, signalHandler);

    const char *serverIP = argv[1];
    int syncPeriod = atoi(argv[2]);

    sockfd = socket(AF_INET, SOCK_DGRAM, 0);
    if (sockfd < 0) {
        cerr << "[ERROR] Socket creation failed" << endl;
        return -1;
    }

    struct timeval timeout;
    timeout.tv_sec = 2;
    timeout.tv_usec = 0;
    setsockopt(sockfd, SOL_SOCKET, SO_RCVTIMEO, &timeout, sizeof(timeout));

    memset(&serverAddr, 0, sizeof(serverAddr));
    serverAddr.sin_family = AF_INET;
    serverAddr.sin_port = htons(8080);
    if (inet_pton(AF_INET, serverIP, &serverAddr.sin_addr) <= 0) {
        cerr << "[ERROR] Invalid IP address" << endl;
        close(sockfd);
        return -1;
    }

    cout << "[CLIENT] Syncing with " << serverIP << " every " << syncPeriod << " ms" << endl;

    vector<int64_t> corrections;
    vector<int64_t> timeDifferences;
    vector<int64_t> networkDelays;
    int syncCount = 0;
    uint64_t lastLocalTime = getCurrentTimeMs();

    OStime = getCurrentTimeMs();
    Cc = OStime;

    while (running) {
        try {
            uint64_t localBefore = getCurrentTimeMs();
            uint64_t serverTime = getServerTime();
            uint64_t localAfter = getCurrentTimeMs();

            int64_t networkDelay = (localAfter - localBefore) / 2;
            networkDelays.push_back(networkDelay);

            int64_t correction = (serverTime + networkDelay) - localAfter;
            corrections.push_back(correction);

            if (corrections.size() >= 3) {
                vector<int64_t> sorted = corrections;
                sort(sorted.begin(), sorted.end());
                int64_t medianCorrection = sorted[sorted.size() / 2];
                applyTimeCorrection(medianCorrection);
            } else {
                applyTimeCorrection(correction);
            }

            int64_t timeDiff = Cc - getCurrentTimeMs();
            timeDifferences.push_back(timeDiff);

            syncCount++;

            cout << "[SYNC #" << syncCount << "]" << endl;
            cout << "  Server time: " << serverTime << " ms" << endl;
            cout << "  Local time: " << localAfter << " ms" << endl;
            cout << "  Network delay: " << networkDelay << " ms" << endl;
            cout << "  Correction: " << correction << " ms" << endl;
            cout << "  Corrected OS time (OStime): " << OStime << " ms" << endl;
            cout << "  Client corrected time (Cc): " << Cc << " ms" << endl;
            cout << "  Difference (Cc - current): " << timeDiff << " ms" << endl;

            if (syncCount % 10 == 0) {
                printStats(corrections, timeDifferences);
                corrections.clear();
                timeDifferences.clear();
            }

        } catch (const exception &e) {
            cerr << "[ERROR] Sync failed: " << e.what() << endl;

            OStime = getCurrentTimeMs();
            Cc = OStime;
        }

        this_thread::sleep_for(chrono::milliseconds(syncPeriod));
    }

    cleanup();
    return 0;
}