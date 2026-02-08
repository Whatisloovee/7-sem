import dgram from 'dgram';
import fs from 'fs';
import path from 'path';

interface Config {
  servers: string[];
  port: number;
  mediatorIp: string;
  checkInterval: number;
  timeout: number;
}

function ipToNumber(ip: string) {
  return ip.split('.').map(Number).reduce((acc, part) => (acc << 8) + part, 0);
}

const config: Config = JSON.parse(fs.readFileSync(path.join(__dirname, '../../config.json'), 'utf-8'));
let currentCoordinator = config.servers.slice().sort((a, b) => ipToNumber(b) - ipToNumber(a))[0];
let serverStatus = new Map<string, { status: 'online' | 'offline', lastCheck: number }>();

config.servers.forEach(server => {
  serverStatus.set(server, { status: 'online', lastCheck: Date.now() });
});

const socket = dgram.createSocket('udp4');

function checkAllServers() {
  config.servers.forEach(server => {
    checkServerHealth(server);
  });
}

function checkServerHealth(serverIp: string) {
  const healthSocket = dgram.createSocket('udp4');
  let responded = false;

  const timeout = setTimeout(() => {
    if (!responded) {
      updateServerStatus(serverIp, 'offline');
      if (serverIp === currentCoordinator) {
        console.log(`[FAILURE] Обнаружен сбой в работе координатора ${currentCoordinator}`);
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
    healthSocket.close();
  });

  healthSocket.send('PING', config.port, serverIp, (err) => {
    if (err) {
      updateServerStatus(serverIp, 'offline');
      healthSocket.close();
    }
  });
}

function updateServerStatus(serverIp: string, status: 'online' | 'offline') {
  const previousStatus = serverStatus.get(serverIp)?.status;
  
  if (previousStatus !== status) {
    if (status === 'offline') {
      console.log(`[FAILURE] Обнаружен сбой в работе сервера ${serverIp}`);
    } else {
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
    console.log(`[FAILURE] Нет доступных серверов в кластере!`);
    currentCoordinator = '';
    return;
  }
  
  const newCoordinator = onlineServers.slice().sort((a, b) => ipToNumber(b) - ipToNumber(a))[0];
  
  if (newCoordinator !== currentCoordinator) {
    console.log(`[COORDINATOR CHANGE] Установлен новый координатор: ${newCoordinator}`);
    currentCoordinator = newCoordinator;
  }
}

function checkCurrentCoordinator() {
  if (!currentCoordinator) {
    findNewCoordinator();
    return;
  }

  const healthSocket = dgram.createSocket('udp4');
  let responded = false;

  const timeout = setTimeout(() => {
    if (!responded) {
      updateServerStatus(currentCoordinator, 'offline');
      findNewCoordinator();
    }
    healthSocket.close();
  }, config.timeout);

  healthSocket.on('message', (msg) => {
    if (msg.toString() === 'PONG') {
      responded = true;
      updateServerStatus(currentCoordinator, 'online');
      clearTimeout(timeout);
      healthSocket.close();
    }
  });

  healthSocket.send('PING', config.port, currentCoordinator, (err) => {
    if (err) {
      updateServerStatus(currentCoordinator, 'offline');
      findNewCoordinator();
      healthSocket.close();
    }
  });
}

socket.on('message', (msg, rinfo) => {
  const clientIp = rinfo.address;
  const clientPort = rinfo.port;
  const message = msg.toString();

  if (message === 'TIME') {
    if (!currentCoordinator) {
      socket.send('ERROR: No coordinator available', clientPort, clientIp);
      return;
    }
    
    console.log(`[PROTOCOL] Клиент ${clientIp} → координатор ${currentCoordinator}`);

    const proxy = dgram.createSocket('udp4');
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
        proxy.close();
      }
    });

    proxy.on('error', (err) => {
      if (!responded) {
        socket.send('ERROR: Proxy error', clientPort, clientIp);
      }
    });

    proxy.send('TIME', config.port, currentCoordinator, (err) => {
      if (err) {
        if (!responded) {
          socket.send('ERROR: Cannot reach coordinator', clientPort, clientIp);
          proxy.close();
          updateServerStatus(currentCoordinator, 'offline');
          findNewCoordinator();
        }
      }
    });
  }

  else if (message.startsWith('COORDINATOR:')) {
    const newCoord = message.split(':')[1];
    if (currentCoordinator !== newCoord) {
      console.log(`[COORDINATOR UPDATE] Новый координатор: ${newCoord}`);
      currentCoordinator = newCoord;
      updateServerStatus(newCoord, 'online');
    }
  }

  else if (message === 'PONG') {
    updateServerStatus(rinfo.address, 'online');
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
});

setInterval(() => {
  checkAllServers();
}, config.checkInterval);

setInterval(() => {
  if (currentCoordinator) {
    checkCurrentCoordinator();
  }
}, config.checkInterval / 2);

socket.bind(config.port, config.mediatorIp);