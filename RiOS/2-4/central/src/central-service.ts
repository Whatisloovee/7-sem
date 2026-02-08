import express, { Request, Response } from 'express';
import axios from 'axios';
import { Pool } from 'pg';
import winston from 'winston';
import dotenv from 'dotenv';

// Load environment variables
dotenv.config({ path: 'D:/Desktop/study_7_sem/RiOS/2-4/central/.env' });

// Logger setup
const logger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.json()
  ),
  transports: [
    new winston.transports.File({ filename: 'central-service.log' }),
    new winston.transports.Console()
  ]
});

// PostgreSQL pool
const pool = new Pool({
  user: process.env.PG_USER || 'postgres',
  host: process.env.PG_HOST || 'localhost',
  database: process.env.PG_DATABASE || 'central_db',
  password: process.env.PG_PASSWORD || 'password',
  port: parseInt(process.env.PG_PORT || '5432')
});

// Interfaces
interface TelemetryData {
  object_id: number;
  value: number;
  timestamp: string;
}

interface ServiceStatus {
  service: string;
  status: string;
  lastChecked: string;
}

// Initialize database
async function initDb() {
  try {
    await pool.query(`
      CREATE TABLE IF NOT EXISTS telemetry (
        id SERIAL PRIMARY KEY,
        object_id INTEGER,
        value FLOAT,
        timestamp TIMESTAMP,
        source VARCHAR(50),
        is_synchronized BOOLEAN DEFAULT false
      )
    `);
    logger.info('Database initialized');
  } catch (error) {
    logger.error('Database initialization failed', error);
  }
}

// Time synchronization middleware
const timeSyncMiddleware = (req: Request, res: Response, next: () => void) => {
  const serverTime = new Date().toISOString();
  res.setHeader('X-Server-Time', serverTime);
  const clientTime = req.get('X-Client-Time');
  if (clientTime) {
    const timeDiff = new Date(serverTime).getTime() - new Date(clientTime).getTime();
    logger.info(`Time difference with client: ${timeDiff}ms`);
  }
  next();
};

// Express app
const app = express();
app.use(express.json());
app.use(timeSyncMiddleware);

// Health check endpoint
app.get('/status', async (req: Request, res: Response) => {
  const statuses: ServiceStatus[] = [];
  const services = [
    process.env.TERRITORIAL_1_URL || 'http://10.95.30.87:3001',
    process.env.TERRITORIAL_2_URL || 'http://10.95.30.87:3002'
  ];

  for (const service of services) {
    try {
      await axios.get(`${service}/status`, {
        headers: { 'X-Client-Time': new Date().toISOString() }
      });
      statuses.push({ service, status: 'OK', lastChecked: new Date().toISOString() });
    } catch (error) {
      statuses.push({ service, status: 'DOWN', lastChecked: new Date().toISOString() });
      logger.error(`Service ${service} is down`, error);
    }
  }

  res.json(statuses);
});

// Pull replication endpoint
app.get('/pull-data', async (req: Request, res: Response) => {
  const services = [
    process.env.TERRITORIAL_1_URL || 'http://localhost:3001',
    process.env.TERRITORIAL_2_URL || 'http://localhost:3002'
  ];

  for (const service of services) {
    try {
      const response: any = await axios.get(`${service}/telemetry`, {
        headers: { 'X-Client-Time': new Date().toISOString() }
      });
      const data: TelemetryData[] = response.data;

      for (const item of data) {
        await pool.query(
          'INSERT INTO telemetry (object_id, value, timestamp, source) VALUES ($1, $2, $3, $4)',
          [item.object_id, item.value, item.timestamp, service]
        );
      }
      logger.info(`Pulled ${data.length} records from ${service}`);
    } catch (error) {
      logger.error(`Failed to pull data from ${service}`, error);
    }
  }

  res.json({ status: 'Pull replication completed' });
});

// Push replication endpoint
app.post('/push-data', async (req: Request, res: Response) => {
  const services = [
    process.env.TERRITORIAL_1_URL || 'http://localhost:3001',
    process.env.TERRITORIAL_2_URL || 'http://localhost:3002'
  ];

  try {
    for (const service of services) {
    const result = await pool.query('SELECT * FROM telemetry WHERE is_synchronized = false AND source != $1 ORDER BY timestamp DESC LIMIT 5', [service]);
    const data: TelemetryData[] = result.rows.map(row => ({
      object_id: row.object_id,
      value: row.value,
      timestamp: row.timestamp
    }));
    for(const option of data)
    await pool.query('UPDATE telemetry SET is_synchronized = true WHERE object_id = $1 AND value = $2 AND timestamp = $3', [option.object_id, option.value, option.timestamp]);
      try {
        await axios.post(`${service}/receive-data`, data, {
          headers: { 'X-Client-Time': new Date().toISOString() }
        });
        logger.info(`Pushed ${data.length} records to ${service}`);
      } catch (error) {
        logger.error(`Failed to push data to ${service}`, error);
      }
    }

    res.json({ status: 'Push replication completed' });
  } catch (error) {
    logger.error('Push replication failed', error);
    res.status(500).json({ error: 'Push replication failed' });
  }
});

// Start server
const PORT = process.env.PORT || 3000;
app.listen(PORT, async () => {
  await initDb();
  logger.info(`Central service running on port ${PORT}`);
});