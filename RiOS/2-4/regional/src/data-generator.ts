import { Pool } from 'pg';
import winston from 'winston';
import dotenv from 'dotenv';

// Load environment variables
dotenv.config();

// Logger setup
const logger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.json()
  ),
  transports: [
    new winston.transports.File({ filename: 'data-generator.log' }),
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

// Generate random telemetry data
async function generateData() {
  try {
    // Assume student ID range 1-100 for value generation
    const objects = Array.from({ length: 10 }, (_, i) => i + 1); // 10 objects
    const recordsPerObject = 10; // 10 records per object

    for (const objectId of objects) {
      for (let i = 0; i < recordsPerObject; i++) {
        const value = Math.random() * 5; // Random value between 0 and 5
        const timestamp = new Date(Date.now() - Math.floor(Math.random() * 30 * 24 * 60 * 60 * 1000)).toISOString(); // Random timestamp within last 30 days
        await pool.query(
          'INSERT INTO telemetry (object_id, value, timestamp) VALUES ($1, $2, $3)',
          [objectId, value, timestamp]
        );
      }
    }
    logger.info(`Generated ${objects.length * recordsPerObject} telemetry records`);
  } catch (error) {
    logger.error('Data generation failed', error);
  } finally {
    await pool.end();
  }
}

// Initialize database and generate data
async function main() {
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
    await generateData();
  } catch (error) {
    logger.error('Initialization failed', error);
  }
}

main();