import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import { CentralPollingService } from './services/EnhancedPollingService';
import { CENTRAL_CONFIG } from './config';
import { logger } from './utils/logger';

class CentralService {
  private app: express.Application;
  private pollingService: CentralPollingService;

  constructor() {
    this.app = express();
    this.setupMiddleware();
    this.setupRoutes();
    
    this.pollingService = new CentralPollingService();
  }

  private setupMiddleware(): void {
    this.app.use(helmet());
    this.app.use(cors({
      origin: process.env.CORS_ORIGIN || "*"
    }));
    this.app.use(express.json());
  }

  private setupRoutes(): void {
    // Статус всех сервисов
    this.app.get('/api/services/status', (req, res) => {
      const status = this.pollingService.getServicesStatus();
      res.json({
        success: true,
        data: status,
        timestamp: new Date().toISOString()
      });
    });

    // Принудительный опрос
    this.app.post('/api/poll/now', async (req, res) => {
      try {
        const data = await this.pollingService.forcePoll();
        res.json({
          success: true,
          data: data,
          message: 'Опрос выполнен'
        });
      } catch (error: any) {
        res.status(500).json({
          success: false,
          error: error.message
        });
      }
    });

    // Health check
    this.app.get('/health', (req, res) => {
      res.json({
        status: 'OK',
        service: 'central-telemetry-service',
        timestamp: new Date().toISOString(),
        sources: CENTRAL_CONFIG.DATA_SOURCES
      });
    });
    this.app.get('/api/services/status/detailed', (req, res) => {
        try {
          const detailedStatus = this.pollingService.getDetailedServicesStatus();
          
          logger.info('Запрос детального статуса сервисов', {
            client: req.ip,
            userAgent: req.get('User-Agent')
          });
    
          res.json({
            success: true,
            data: detailedStatus,
            timestamp: new Date().toISOString()
          });
        } catch (error: any) {
          logger.error('Ошибка получения детального статуса', {
            error: error.message,
            stack: error.stack
          });
          res.status(500).json({
            success: false,
            error: 'Internal server error'
          });
        }
      });
    
      // Статус конкретного сервиса
      this.app.get('/api/services/:serviceUrl/health', (req, res) => {
        try {
          const serviceUrl = decodeURIComponent(req.params.serviceUrl);
          const health = this.pollingService.getServiceHealth(serviceUrl);
    
          logger.debug('Запрос здоровья сервиса', {
            service: serviceUrl,
            client: req.ip
          });
    
          res.json({
            success: true,
            data: health,
            timestamp: new Date().toISOString()
          });
        } catch (error: any) {
          logger.error('Ошибка получения здоровья сервиса', {
            service: req.params.serviceUrl,
            error: error.message
          });
          res.status(500).json({
            success: false,
            error: 'Internal server error'
          });
        }
      });
    
      // Статистика системы
      this.app.get('/api/system/stats', (req, res) => {
        try {
          const detailedStatus = this.pollingService.getDetailedServicesStatus();
          
          const stats = {
            uptime: process.uptime(),
            memory: process.memoryUsage(),
            timestamp: new Date().toISOString(),
            ...detailedStatus.summary
          };
    
          logger.debug('Запрос статистики системы', {
            client: req.ip
          });
    
          res.json({
            success: true,
            data: stats
          });
        } catch (error: any) {
          logger.error('Ошибка получения статистики системы', {
            error: error.message
          });
          res.status(500).json({
            success: false,
            error: 'Internal server error'
          });
        }
      });
    
      // Логи системы (огранниченный доступ)
      this.app.get('/api/system/logs', (req, res) => {
        // В реальной системе здесь была бы аутентификация и авторизация
        logger.warn('Попытка доступа к логам системы', {
          client: req.ip,
          userAgent: req.get('User-Agent')
        });
    
        res.json({
          success: true,
          message: 'Логи доступны в файловой системе',
          logFiles: [
            'logs/combined-*.log',
            'logs/error-*.log', 
            'logs/telemetry-*.log'
          ]
        });
      });
    }

  public async start(): Promise<void> {
    // Запускаем фоновый опрос
    this.pollingService.startBackgroundPolling();

    this.app.listen(CENTRAL_CONFIG.PORT, () => {
      logger.info('🚀 ЦЕНТРАЛЬНЫЙ СЕРВИС ЗАПУЩЕН', {
        port: CENTRAL_CONFIG.PORT,
        sources: CENTRAL_CONFIG.DATA_SOURCES,
        interval: CENTRAL_CONFIG.POLLING_INTERVAL
      });
    });
  }
}

// Запуск сервиса
const service = new CentralService();
service.start().catch(console.error);