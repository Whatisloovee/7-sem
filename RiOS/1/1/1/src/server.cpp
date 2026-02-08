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
#include "get_sync.h"
#include "set_sync.h"
#include "client_stats.h"

using namespace std;

int sockfd = -1;
chrono::steady_clock::time_point serverStartTime;
map<string, ClientStats> clients;

string getClientKey(const sockaddr_in &addr) {
    stringstream ss;
    ss << inet_ntoa(addr.sin_addr) << ":" << ntohs(addr.sin_port);
    return ss.str();
}

int getServerUptime() {
    auto now = chrono::steady_clock::now();
    return chrono::duration_cast<chrono::milliseconds>(now - serverStartTime).count();
}

int calculateCorrection(int clientTime) {
    int serverTime = getServerUptime();
    return serverTime - clientTime;
}

void handleSyncRequest(const sockaddr_in &clientAddr, const GetSync &request) {
    string clientKey = getClientKey(clientAddr);
    ClientStats &stats = clients[clientKey];

    if (stats.requestCount == 0) {
        stats.state = CONNECTED;
        cout << "New client connected: " << clientKey << endl;
    }

    if (stats.state != CONNECTED) {
        cout << "Ignoring request from disconnected client: " << clientKey << endl;
        return;
    }

    int correction = calculateCorrection(request.currentValue);

    SetSync response{};
    strncpy(response.cmd, "SYNC", 4);
    response.correction = correction;

    sendto(sockfd, &response, sizeof(response), 0,
           (struct sockaddr *) &clientAddr, sizeof(clientAddr));

    stats.requestCount++;
    if (stats.requestCount != 1) {
        stats.totalCorrection += correction;
    }
    stats.averageCorrection = (double) stats.totalCorrection / stats.requestCount;

    if (stats.requestCount % 10 == 0) {
        cout << "[" << clientKey << "] Request #" << stats.requestCount
                << " | Correction: " << correction
                << " | Average: " << stats.averageCorrection << endl;
    } else {
        cout << "[" << clientKey << "] #" << stats.requestCount
                << " correction: " << correction << endl;
    }
}

void handleDisconnect(const string &clientKey) {
    auto it = clients.find(clientKey);
    if (it != clients.end()) {
        it->second.state = DISCONNECTED;
        cout << "Client disconnected: " << clientKey
                << " (Total requests: " << it->second.requestCount << ")" << endl;
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
    return true;
}

void run() {
    sockaddr_in clientAddr{};
    socklen_t clientLen = sizeof(clientAddr);
    GetSync request;

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
    }
}

void cleanup() {
    if (sockfd >= 0) {
        close(sockfd);
    }
}

int main() {
    if (!initialize()) {
        return -1;
    }
    run();
    cleanup();
    return 0;
}
