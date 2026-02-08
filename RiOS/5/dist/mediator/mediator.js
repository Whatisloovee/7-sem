"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const dgram_1 = __importDefault(require("dgram"));
const fs_1 = __importDefault(require("fs"));
const path_1 = __importDefault(require("path"));
function ipToNumber(ip) {
    return ip.split('.').map(Number).reduce((acc, part) => (acc << 8) + part, 0);
}
const config = JSON.parse(fs_1.default.readFileSync(path_1.default.join(__dirname, '../../config.json'), 'utf-8'));
let currentCoordinator = config.servers.slice().sort((a, b) => ipToNumber(b) - ipToNumber(a))[0];
let lastCoordinatorUpdate = Date.now();
let serverStatus = new Map();
config.servers.forEach(server => {
    serverStatus.set(server, { status: 'online', lastCheck: Date.now() });
});
const socket = dgram_1.default.createSocket('udp4');
function checkAllServers() {
    config.servers.forEach(server => {
        checkServerHealth(server);
    });
}
function checkServerHealth(serverIp) {
    const healthSocket = dgram_1.default.createSocket('udp4');
    let responded = false;
    const timeout = setTimeout(() => {
        if (!responded) {
            updateServerStatus(serverIp, 'offline');
            if (serverIp === currentCoordinator) {
                console.log(`[CRITICAL] Координатор ${currentCoordinator} отключился! Ищу новый...`);
                findNewCoordinator();
            }
        }
        healthSocket.close();
    }, config.timeout);
    healthSocket.on('message', (msg, rinfo) => {
        if (msg.toString() === 'PONG' && rinfo.address === serverIp) {
            responded = true;
            updateServerStatus(serverIp, 'online');
            clearTimeout(timeout);
            healthSocket.close();
        }
    });
    healthSocket.on('error', (err) => {
        console.log(`[HEALTH ERROR] ${serverIp}: ${err.message}`);
        healthSocket.close();
    });
    healthSocket.send('PING', config.port, serverIp, (err) => {
        if (err) {
            console.log(`[HEALTH ERROR] ${serverIp}: ${err.message}`);
            updateServerStatus(serverIp, 'offline');
            healthSocket.close();
        }
    });
}
function updateServerStatus(serverIp, status) {
    const previousStatus = serverStatus.get(serverIp)?.status;
    if (previousStatus !== status) {
        console.log(`\n=== [STATUS CHANGE] Сервер ${serverIp}: ${previousStatus} → ${status} ===`);
        if (status === 'offline') {
            console.log(`[FAILURE] Обнаружен сбой в работе сервера ${serverIp}`);
        }
        else {
            console.log(`[RECOVERY] Сервер ${serverIp} восстановил работу`);
        }
    }
    serverStatus.set(serverIp, { status, lastCheck: Date.now() });
}
function findNewCoordinator() {
    const onlineServers = config.servers.filter(server => {
        const status = serverStatus.get(server);
        return status?.status === 'online';
    });
    if (onlineServers.length === 0) {
        console.log(`[CRITICAL] Нет доступных серверов в кластере!`);
        currentCoordinator = '';
        return;
    }
    const newCoordinator = onlineServers.slice().sort((a, b) => ipToNumber(b) - ipToNumber(a))[0];
    if (newCoordinator !== currentCoordinator) {
        console.log(`\n=== [COORDINATOR CHANGE] ${currentCoordinator} → ${newCoordinator} ===`);
        currentCoordinator = newCoordinator;
        lastCoordinatorUpdate = Date.now();
        console.log(`[NEW COORDINATOR] Установлен новый координатор: ${currentCoordinator}`);
    }
    else {
        console.log(`[COORDINATOR] Текущий координатор ${currentCoordinator} остается активным`);
    }
}
function checkCurrentCoordinator() {
    const healthSocket = dgram_1.default.createSocket('udp4');
    let responded = false;
    const timeout = setTimeout(() => {
        if (!responded) {
            console.log(`[COORDINATOR DOWN] Координатор ${currentCoordinator} не отвечает!`);
            updateServerStatus(currentCoordinator, 'offline');
            findNewCoordinator();
        }
        healthSocket.close();
    }, config.timeout);
    healthSocket.on('message', (msg) => {
        if (msg.toString() === 'PONG') {
            responded = true;
            console.log(`[COORDINATOR UP] Координатор ${currentCoordinator} доступен`);
            updateServerStatus(currentCoordinator, 'online');
            clearTimeout(timeout);
            healthSocket.close();
        }
    });
    healthSocket.send('PING', config.port, currentCoordinator, (err) => {
        if (err) {
            console.log(`[HEALTH ERROR] ${currentCoordinator}: ${err.message}`);
            updateServerStatus(currentCoordinator, 'offline');
            findNewCoordinator();
            healthSocket.close();
        }
    });
}
function printServerStatus() {
    config.servers.forEach(server => {
        const status = serverStatus.get(server);
        const marker = server === currentCoordinator ? ' (COORDINATOR)' : '';
    });
}
socket.on('message', (msg, rinfo) => {
    const clientIp = rinfo.address;
    const clientPort = rinfo.port;
    const message = msg.toString();
    console.log(`[RECEIVED] От ${clientIp}:${clientPort}: ${message}`);
    if (message === 'TIME') {
        if (!currentCoordinator) {
            socket.send('ERROR: No coordinator available', clientPort, clientIp);
            return;
        }
        console.log(`[REQUEST] Запрос времени от ${clientIp} → перенаправляю к ${currentCoordinator}`);
        const proxy = dgram_1.default.createSocket('udp4');
        let responded = false;
        const timeout = setTimeout(() => {
            if (!responded) {
                socket.send('ERROR: Service unavailable', clientPort, clientIp);
                proxy.close();
                updateServerStatus(currentCoordinator, 'offline');
                findNewCoordinator();
            }
        }, 1500);
        proxy.on('message', (response, proxyRinfo) => {
            if (!responded && proxyRinfo.address === currentCoordinator) {
                responded = true;
                clearTimeout(timeout);
                const time = response.toString();
                socket.send(time, clientPort, clientIp);
                console.log(`[RESPONSE] ${clientIp} ← ${currentCoordinator}: ${time}`);
                proxy.close();
            }
        });
        proxy.on('error', (err) => {
            console.log(`[PROXY ERROR] ${err.message}`);
            if (!responded) {
                socket.send('ERROR: Proxy error', clientPort, clientIp);
            }
        });
        proxy.send('TIME', config.port, currentCoordinator, (err) => {
            if (err) {
                console.log(`[SEND ERROR] к ${currentCoordinator}: ${err.message}`);
                if (!responded) {
                    socket.send('ERROR: Cannot reach coordinator', clientPort, clientIp);
                    proxy.close();
                    updateServerStatus(currentCoordinator, 'offline');
                    findNewCoordinator();
                }
            }
            else {
                console.log(`[PROXY] Запрос отправлен к координатору ${currentCoordinator}`);
            }
        });
    }
    else if (message.startsWith('COORDINATOR:')) {
        const newCoord = message.split(':')[1];
        if (currentCoordinator !== newCoord) {
            console.log(`\n=== [UPDATE] Новый координатор: ${newCoord} ===`);
            currentCoordinator = newCoord;
            lastCoordinatorUpdate = Date.now();
            updateServerStatus(newCoord, 'online');
        }
        else {
        }
    }
    else if (message === 'PONG') {
        console.log(`[PONG] От ${clientIp}`);
        updateServerStatus(clientIp, 'online');
    }
});
socket.on('error', (err) => {
    console.error(`[SOCKET ERROR] ${err}`);
});
socket.on('listening', () => {
    const address = socket.address();
    console.log(`Посредник запущен на ${address.address}:${address.port}`);
    console.log(`Начальный координатор: ${currentCoordinator}`);
    console.log(`Серверы в кластере: ${config.servers.join(', ')}`);
    setTimeout(() => {
        printServerStatus();
    }, 1000);
});
setInterval(() => {
    checkAllServers();
    printServerStatus();
}, config.checkInterval);
setInterval(() => {
    if (currentCoordinator) {
        checkCurrentCoordinator();
    }
}, config.checkInterval / 2);
socket.bind(config.port, config.mediatorIp);
