import dgram from 'dgram';
import fs from 'fs';
import path from 'path';

interface Config {
  servers: string[];
  port: number;
  checkInterval: number;
  timeout: number;
  mediatorIp: string;
}

const config: Config = JSON.parse(fs.readFileSync(path.join(__dirname, '../../config.json'), 'utf-8'));
const MY_IP = process.argv[2];
if (!MY_IP || !config.servers.includes(MY_IP)) {
  console.error('Укажите свой IP: npm run start:server -- 192.168.1.101');
  process.exit(1);
}

const socket = dgram.createSocket('udp4');
let coordinator = getHighestIp();
let isElectionInProgress = false;
let electionTimeout: NodeJS.Timeout | null = null;
let coordinatorFailCount = 0;

function ipToNumber(ip: string) {
  return ip.split('.').map(Number).reduce((acc, part) => (acc << 8) + part, 0);
}

function getHighestIp() {
  return config.servers.slice().sort((a, b) => ipToNumber(b) - ipToNumber(a))[0];
}

function getHigherIps() {
  return config.servers.filter(ip => ipToNumber(ip) > ipToNumber(MY_IP));
}

function formatTime(): string {
  const now = new Date();
  const pad = (n: number) => n.toString().padStart(2, '0');
  return `${pad(now.getDate())}${pad(now.getMonth() + 1)}${now.getFullYear()}:${pad(now.getHours())}:${pad(now.getMinutes())}:${pad(now.getSeconds())}`;
}

function startElection() {
  if (isElectionInProgress) return;
  
  isElectionInProgress = true;
  console.log(`[ELECTION] Начало выборов нового координатора`);

  const higher = getHigherIps();
  
  if (higher.length === 0) {
    coordinator = MY_IP;
    isElectionInProgress = false;
    console.log(`[ELECTION] Сервер ${MY_IP} стал координатором`);
    broadcastCoordinator();
    return;
  }

  let receivedOk = false;

  higher.forEach(ip => {
    socket.send('ELECTION', config.port, ip, (error) => {
      if (error) {
        console.log(`[ELECTION] Ошибка отправки ELECTION на ${ip}`);
      }
    });
  });

  electionTimeout = setTimeout(() => {
    if (isElectionInProgress && !receivedOk) {
      coordinator = MY_IP;
      isElectionInProgress = false;
      console.log(`[ELECTION] Сервер ${MY_IP} стал координатором`);
      broadcastCoordinator();
    }
  }, config.timeout * 3);

  const okHandler = (msg: Buffer, rinfo: dgram.RemoteInfo) => {
    if (msg.toString() === 'OK' && higher.includes(rinfo.address)) {
      receivedOk = true;
      isElectionInProgress = false;
      if (electionTimeout) clearTimeout(electionTimeout);
      socket.removeListener('message', okHandler);
    }
  };

  socket.on('message', okHandler);
}

function broadcastCoordinator() {
  const msg = `COORDINATOR:${MY_IP}`;
  
  const recipients = [
    ...config.servers.filter(ip => ip !== MY_IP),
    config.mediatorIp
  ];
  
  recipients.forEach(ip => {
    socket.send(msg, config.port, ip, (error) => {
      if (error) {
        console.log(`[BROADCAST] Ошибка отправки координатора на ${ip}`);
      }
    });
  });
}

async function checkCoordinator() {
  if (MY_IP === coordinator || isElectionInProgress) return;

  return new Promise((resolve) => {
    let responded = false;
    const checkSocket = dgram.createSocket('udp4');

    const timeoutId = setTimeout(() => {
      if (!responded) {
        coordinatorFailCount++;
        console.log(`[HEALTH CHECK] Координатор ${coordinator} не ответил (попытка ${coordinatorFailCount}/3)`);
        
        if (coordinatorFailCount >= 3) {
          console.log(`[HEALTH CHECK] Координатор недоступен, начинаю выборы`);
          coordinatorFailCount = 0;
          startElection();
        }
      }
      checkSocket.close();
      resolve(false);
    }, config.timeout);

    checkSocket.on('message', (msg, rinfo) => {
      if (msg.toString() === 'PONG' && rinfo.address === coordinator) {
        responded = true;
        coordinatorFailCount = 0;
        clearTimeout(timeoutId);
        checkSocket.close();
        resolve(true);
      }
    });
    
    checkSocket.on('error', (err) => {
      clearTimeout(timeoutId);
      checkSocket.close();
      resolve(false);
    });

    checkSocket.bind(() => {
      checkSocket.send('PING', config.port, coordinator, (err) => {
        if (err) {
          clearTimeout(timeoutId);
          checkSocket.close();
          resolve(false);
        }
      });
    });
  });
}

socket.on('message', (msg, rinfo) => {
  const str = msg.toString();

  if (str === 'TIME') {
    if (coordinator === MY_IP) {
      const time = formatTime();
      socket.send(time, rinfo.port, rinfo.address);
    }
    return;
  }

  if (str === 'PING') {
    socket.send('PONG', rinfo.port, rinfo.address);
    return;
  }

  if (str === 'ELECTION') {
    socket.send('OK', rinfo.port, rinfo.address);
    if (!isElectionInProgress) startElection();
    return;
  }

  if (str.startsWith('COORDINATOR:')) {
    const newCoord = str.split(':')[1];
    if (coordinator !== newCoord) {
      console.log(`[COORDINATOR] Новый координатор: ${newCoord}`);
      coordinator = newCoord;
      coordinatorFailCount = 0;
    }
    return;
  }
});

socket.on('error', (err) => {
  console.error(`[SOCKET ERROR]`, err);
});

socket.bind(config.port, MY_IP, () => {
  console.log(`Сервер СВВ запущен на ${MY_IP}:${config.port}`);
  
  if (MY_IP === getHighestIp()) {
    console.log(`[INIT] Сервер ${MY_IP} является начальным координатором`);
    broadcastCoordinator();
  }
  
  setInterval(() => {
    checkCoordinator();
  }, config.checkInterval);
});