import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import { TelemetryGenerator } from './services/TelemetryGenerator';
import { SOURCE_CONFIG } from './config';
import { logger } from './utils/logger';

class TelemetrySource {
  private app: express.Application;
  private telemetryGenerator: TelemetryGenerator;

  constructor() {
    this.app = express();
    this.telemetryGenerator = new TelemetryGenerator(SOURCE_CONFIG.SOURCE_NAME);
    this.setupMiddleware();
    this.setupRoutes();
  }

  private setupMiddleware(): void {
    this.app.use(helmet());
    this.app.use(cors({
      origin: process.env.CORS_ORIGIN || "*"
    }));
    this.app.use(express.json());
  }

  private setupRoutes(): void {
    // Основной эндпоинт для получения телеметрии
    this.app.get('/api/telemetry', (req, res) => {
      try {
        // Имитация случайных сбоев (5%)
        if (Math.random() < 0.05) {
          throw new Error('Имитация сбоя сервиса');
        }

        // Имитация задержки сети
        const delay = Math.random() * 1000;
        setTimeout(() => {
          const data = this.telemetryGenerator.generateData();
          res.json(data);
        }, delay);

      } catch (error: any) {
        logger.error('Ошибка генерации телеметрии:', error);
        res.status(500).json({
          error: 'Service temporarily unavailable',
          source: SOURCE_CONFIG.SOURCE_NAME
        });
      }
    });

    // Статус сервиса
    this.app.get('/api/status', (req, res) => {
      res.json({
        status: 'operational',
        source: SOURCE_CONFIG.SOURCE_NAME,
        uptime: process.uptime(),
        timestamp: new Date().toISOString()
      });
    });

    // Health check
    this.app.get('/health', (req, res) => {
      res.json({
        status: 'healthy',
        service: SOURCE_CONFIG.SOURCE_NAME,
        timestamp: new Date().toISOString()
      });
    });

    // Информация о сервисе
    this.app.get('/api/info', (req, res) => {
      res.json({
        name: SOURCE_CONFIG.SOURCE_NAME,
        version: '1.0.0',
        description: 'Telemetry Data Source Service',
        endpoints: [
          '/api/telemetry - GET - получение телеметрии',
          '/api/status - GET - статус сервиса',
          '/health - GET - проверка здоровья'
        ]
      });
    });
  }

  public start(): void {
    this.app.listen(SOURCE_CONFIG.PORT, SOURCE_CONFIG.HOST, () => {
      logger.info(`📡 ИСТОЧНИК ДАННЫХ ЗАПУЩЕН`, {
        name: SOURCE_CONFIG.SOURCE_NAME,
        host: SOURCE_CONFIG.HOST,
        port: SOURCE_CONFIG.PORT
      });
    });
  }
}

// Запуск сервиса-источника
const source = new TelemetrySource();
source.start();