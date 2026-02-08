import dgram from 'dgram';
import fs from 'fs';
import path from 'path';

interface Config {
  servers: string[];
  port: number;
  mediatorIp: string;
}

const config: Config = JSON.parse(fs.readFileSync(path.join(__dirname, '../../config.json'), 'utf-8'));
const mediatorIp = config.mediatorIp ? config.mediatorIp : '127.0.0.1';
const port = config.port ? config.port : 5555;

const client = dgram.createSocket('udp4');
let isRunning = true;

client.on('message', (msg) => {
  console.log(`Получено: ${msg.toString()}`);
});

client.on('error', (err) => {
  console.error(`[CLIENT ERROR] ${err}`);
  isRunning = false;
});

client.on('close', () => {
  console.log('Клиент закрыт');
  isRunning = false;
});

client.on('listening', () => {
  console.log('Client is listening');
  
  const sendTimeRequest = () => {
    if (!isRunning) {
      console.log('Клиент остановлен, прекращаю отправку запросов');
      return;
    }
    
    console.log('Запрашиваю время...');
    client.send('TIME', port, mediatorIp, (err) => {
      if (err) {
        console.error(`[SEND ERROR] ${err.message}`);
      }
    });
  };
  
  sendTimeRequest();
  
  const intervalId = setInterval(() => {
    if (!isRunning) {
      clearInterval(intervalId);
      return;
    }
    sendTimeRequest();
  }, 3000);
});

client.bind(0);

process.on('SIGINT', () => {
  console.log('\nЗавершаю работу клиента...');
  isRunning = false;
  client.close();
});

process.on('SIGTERM', () => {
  console.log('\nЗавершаю работу клиента...');
  isRunning = false;
  client.close();
});