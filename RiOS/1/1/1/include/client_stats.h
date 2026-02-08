#pragma once

enum ClientState {
    CONNECTED,
    DISCONNECTED
};

struct ClientStats {
    int requestCount = 0;
    int totalCorrection = 0;
    double averageCorrection = 0.0;
    ClientState state = DISCONNECTED;
};
