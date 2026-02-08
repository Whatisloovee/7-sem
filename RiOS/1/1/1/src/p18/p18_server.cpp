#include <iostream>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <cstring>
#include <chrono>
#include <map>
#include <string>
#include <sstream>
#include <vector>
#include <algorithm>
#include <cmath>
#include <climits>

using namespace std;

struct GetSync2 {
    char cmd[4];
    int currentValue;
};

struct SetSync2 {
    char cmd[4];
    int correction;
    int serverTime;
};

enum ConnectionState2 {
    DISCONNECTED,
    CONNECTED
};

class ClientStats2 {
public:
    ConnectionState2 state;
    int requestCount;
    int totalCorrection;
    double averageCorrection;
    int minCorrection;
    int maxCorrection;
    int lastCorrection;

    ClientStats2() : state(DISCONNECTED), requestCount(0), totalCorrection(0),
                     averageCorrection(0), minCorrection(INT_MAX),
                     maxCorrection(INT_MIN), lastCorrection(0) {}
};

int sockfd = -1;
chrono::steady_clock::time_point serverStartTime;
map<string, ClientStats2> clients;
map<string, vector<int>> clientHistory;

const int HISTORY_WINDOW = 5;
const double OUTLIER_THRESHOLD = 2.5;

string getClientKey(const sockaddr_in &addr) {
    stringstream ss;
    ss << inet_ntoa(addr.sin_addr) << ":" << ntohs(addr.sin_port);
    return ss.str();
}

int getServerUptime() {
    auto now = chrono::steady_clock::now();
    return chrono::duration_cast<chrono::milliseconds>(now - serverStartTime).count();
}

int calculateAdvancedCorrection(int clientTime, const string &clientKey) {
    int serverTime = getServerUptime();
    int rawCorrection = serverTime - clientTime;

    ClientStats2 &stats = clients[clientKey];

    if (stats.requestCount < 2) {
        return rawCorrection;
    }

    auto &history = clientHistory[clientKey];
    history.push_back(rawCorrection);

    if (history.size() > HISTORY_WINDOW) {
        history.erase(history.begin());
    }

    if (history.size() < 3) {
        return rawCorrection;
    }

    double sum = 0;
    for (int val: history) {
        sum += val;
    }
    double mean = sum / history.size();

    double variance = 0;
    for (int val: history) {
        variance += pow(val - mean, 2);
    }
    double stddev = sqrt(variance / history.size());

    if (stddev > 0 && abs(rawCorrection - mean) > OUTLIER_THRESHOLD * stddev) {
        vector<int> sorted = history;
        sort(sorted.begin(), sorted.end());
        return sorted[sorted.size() / 2];
    }

    const double alpha = 0.3;
    double smoothed = stats.lastCorrection;

    if (stats.requestCount == 2) {
        smoothed = rawCorrection;
    } else {
        smoothed = alpha * rawCorrection + (1 - alpha) * smoothed;
    }

    return static_cast<int>(smoothed);
}

void handleSyncRequest(const sockaddr_in &clientAddr, const GetSync2 &request) {
    string clientKey = getClientKey(clientAddr);
    ClientStats2 &stats = clients[clientKey];

    if (stats.requestCount == 0) {
        stats.state = CONNECTED;
        cout << "New client connected: " << clientKey << endl;
    }

    if (stats.state != CONNECTED) {
        cout << "Ignoring request from disconnected client: " << clientKey << endl;
        return;
    }

    int correction = calculateAdvancedCorrection(request.currentValue, clientKey);

    SetSync2 response{};
    strncpy(response.cmd, "SYNC", 4);
    response.correction = correction;
    response.serverTime = getServerUptime();

    sendto(sockfd, &response, sizeof(response), 0,
           (struct sockaddr *) &clientAddr, sizeof(clientAddr));

    stats.requestCount++;
    stats.lastCorrection = correction;
    stats.totalCorrection += correction;
    stats.averageCorrection = static_cast<double>(stats.totalCorrection) / stats.requestCount;

    if (correction < stats.minCorrection) {
        stats.minCorrection = correction;
    }
    if (correction > stats.maxCorrection) {
        stats.maxCorrection = correction;
    }

    if (stats.requestCount % 10 == 0) {
        cout << "[" << clientKey << "] Request #" << stats.requestCount
             << " | Correction: " << correction
             << " | Average: " << stats.averageCorrection
             << " | Min: " << stats.minCorrection
             << " | Max: " << stats.maxCorrection << endl;
    } else {
        cout << "[" << clientKey << "] #" << stats.requestCount
             << " correction: " << correction << endl;
    }
}

void handleDisconnect(const string &clientKey) {
    auto it = clients.find(clientKey);
    if (it != clients.end()) {
        it->second.state = DISCONNECTED;

        auto historyIt = clientHistory.find(clientKey);
        if (historyIt != clientHistory.end()) {
            clientHistory.erase(historyIt);
        }

        cout << "Client disconnected: " << clientKey
             << " (Total requests: " << it->second.requestCount
             << ", Avg correction: " << it->second.averageCorrection << ")" << endl;
    }
}

void cleanupClientHistory() {
    vector<string> toRemove;

    for (auto &[clientKey, history]: clientHistory) {
        auto clientIt = clients.find(clientKey);
        if (clientIt == clients.end() || clientIt->second.state == DISCONNECTED) {
            toRemove.push_back(clientKey);
        }
    }

    for (const auto &key: toRemove) {
        clientHistory.erase(key);
    }
}

bool initialize() {
    serverStartTime = chrono::steady_clock::now();

    sockfd = socket(AF_INET, SOCK_DGRAM, 0);
    if (sockfd < 0) {
        cerr << "Socket creation failed" << endl;
        return false;
    }

    int optval = 1;
    setsockopt(sockfd, SOL_SOCKET, SO_REUSEADDR, &optval, sizeof(optval));

    sockaddr_in serverAddr{};
    serverAddr.sin_family = AF_INET;
    serverAddr.sin_addr.s_addr = INADDR_ANY;
    serverAddr.sin_port = htons(8080);

    if (bind(sockfd, (struct sockaddr *) &serverAddr, sizeof(serverAddr)) < 0) {
        cerr << "Bind failed" << endl;
        close(sockfd);
        return false;
    }

    cout << "Time sync server started on port 8080" << endl;
    cout << "Using advanced correction algorithm with:" << endl;
    cout << "  - History window: " << HISTORY_WINDOW << " samples" << endl;
    cout << "  - Outlier threshold: " << OUTLIER_THRESHOLD << " stddev" << endl;
    cout << "  - Exponential smoothing" << endl;

    return true;
}

void run() {
    sockaddr_in clientAddr{};
    socklen_t clientLen = sizeof(clientAddr);
    GetSync2 request;

    auto lastCleanup = chrono::steady_clock::now();

    while (true) {
        memset(&request, 0, sizeof(request));

        ssize_t received = recvfrom(sockfd, &request, sizeof(request), 0,
                                    (struct sockaddr *) &clientAddr, &clientLen);

        if (received != sizeof(request)) {
            continue;
        }

        string clientKey = getClientKey(clientAddr);

        if (strncmp(request.cmd, "DISC", 4) == 0) {
            handleDisconnect(clientKey);
        } else if (strncmp(request.cmd, "GET", 3) == 0) {
            handleSyncRequest(clientAddr, request);
        }

        auto now = chrono::steady_clock::now();
        if (chrono::duration_cast<chrono::seconds>(now - lastCleanup).count() >= 30) {
            cleanupClientHistory();
            lastCleanup = now;
        }
    }
}

void cleanup() {
    if (sockfd >= 0) {
        close(sockfd);
    }
    cout << "Server shutdown complete" << endl;
}

int main() {
    if (!initialize()) {
        return -1;
    }

    try {
        run();
    } catch (const exception &e) {
        cerr << "Server error: " << e.what() << endl;
    }

    cleanup();
    return 0;
}