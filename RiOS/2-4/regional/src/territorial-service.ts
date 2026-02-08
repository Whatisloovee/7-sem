import express, { Request, Response } from 'express';
import { Pool } from 'pg';
import winston from 'winston';
import dotenv from 'dotenv';

// Load environment variables
dotenv.config();
let lastCorrection: any = 0;
// Logger setup
const logger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.json()
  ),
  transports: [
    new winston.transports.File({ filename: 'territorial-service.log' }),
    new winston.transports.Console()
  ]
});

// PostgreSQL pool
const pool = new Pool({
  user: process.env.PG_USER || 'postgres',
  host: process.env.PG_HOST || 'localhost',
  database: process.env.PG_DATABASE || 'territorial_db',
  password: process.env.PG_PASSWORD || 'password',
  port: parseInt(process.env.PG_PORT || '5432')
});

// Interfaces
interface TelemetryData {
  object_id: number;
  value: number;
  timestamp: string;
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
    const timeDiff = new Date(serverTime).getTime() - new Date(clientTime).getTime() - lastCorrection;
    lastCorrection = timeDiff
    logger.info(`Time difference with client: ${timeDiff}ms`);
  }
  next();
};

// Express app
const app = express();
app.use(express.json());
app.use(timeSyncMiddleware);

// Health check endpoint
app.get('/status', (req: Request, res: Response) => {
  res.json({ status: 'OK', timestamp: new Date().toISOString() });
});

// Telemetry data endpoint
app.get('/telemetry', async (req: Request, res: Response) => {
  try {
    const result = await pool.query('SELECT * FROM telemetry WHERE is_synchronized = false');
    const resultUpd = await pool.query('UPDATE telemetry SET is_synchronized = true');
    const data: TelemetryData[] = result.rows.map(row => ({
      object_id: row.object_id,
      value: row.value,
      timestamp: row.timestamp
    }));
    res.json(data);
  } catch (error) {
    logger.error('Failed to fetch telemetry data', error);
    res.status(500).json({ error: 'Failed to fetch data' });
  }
});

// Receive data endpoint for push replication
app.post('/receive-data', async (req: Request, res: Response) => {
  const data: TelemetryData[] = req.body;
  try {
    for (const item of data) {
      await pool.query(
        'INSERT INTO telemetry (object_id, value, timestamp, is_synchronized) VALUES ($1, $2, $3, true)',
        [item.object_id, item.value, item.timestamp]
      );
    }
    logger.info(`Received and stored ${data.length} records`);
    res.json({ status: 'Data received' });
  } catch (error) {
    logger.error('Failed to store received data', error);
    res.status(500).json({ error: 'Failed to store data' });
  }
});

// Start server
const PORT = process.env.PORT || 3001;
app.listen(PORT, async () => {
  await initDb();
  logger.info(`Territorial service running on port ${PORT}`);
});