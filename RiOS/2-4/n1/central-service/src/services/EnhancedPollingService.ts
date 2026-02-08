import axios, { AxiosInstance } from 'axios';
import { CENTRAL_CONFIG } from '../config';
import { HealthMonitor } from './HealthMonitor';
import { logger } from '../utils/advancedLogger';

export interface ServiceStatus {
  url: string;
  isOnline: boolean;
  lastCheck: Date;
  responseTime: number;
  errorCount: number;
  lastError?: string;
  totalRequests: number;
  successfulRequests: number;
}

export interface TelemetryData {
  source: string;
  data: any[];
  timestamp: Date;
  responseTime: number;
}

export class CentralPollingService {
  private httpClient: AxiosInstance;
  private servicesStatus: Map<string, ServiceStatus> = new Map();
  private isPolling: boolean = false;
  private healthMonitor: HealthMonitor;

  constructor() {
    this.httpClient = axios.create({
      timeout: CENTRAL_CONFIG.REQUEST_TIMEOUT
    });

    this.healthMonitor = new HealthMonitor();
    this.initializeServicesStatus();
    
    // Логирование инициализации
    logger.info('Сервис опроса инициализирован', {
      sources: CENTRAL_CONFIG.DATA_SOURCES,
      interval: CENTRAL_CONFIG.POLLING_INTERVAL,
      timeout: CENTRAL_CONFIG.REQUEST_TIMEOUT
    });
  }

  private initializeServicesStatus(): void {
    CENTRAL_CONFIG.DATA_SOURCES.forEach(url => {
      this.servicesStatus.set(url, {
        url,
        isOnline: false,
        lastCheck: new Date(0),
        responseTime: 0,
        errorCount: 0,
        totalRequests: 0,
        successfulRequests: 0
      });
    });
  }

  public startBackgroundPolling(): void {
    if (this.isPolling) {
      logger.warn('Фоновый опрос уже запущен');
      return;
    }

    this.isPolling = true;
    
    logger.info('Запуск фонового опроса сервисов', {
      interval: CENTRAL_CONFIG.POLLING_INTERVAL,
      sourceCount: CENTRAL_CONFIG.DATA_SOURCES.length
    });

    setInterval(() => {
      this.pollAllServices().catch(error => {
        logger.error('Критическая ошибка фонового опроса:', {
          error: error.message,
          stack: error.stack
        });
      });
    }, CENTRAL_CONFIG.POLLING_INTERVAL);

    // Немедленный первый опрос
    setTimeout(() => {
      this.pollAllServices().catch(console.error);
    }, 1000);
  }

  public async forcePoll(): Promise<TelemetryData[]> {
    logger.info('Принудительный опрос запущен');
    return await this.pollAllServices();
  }

  private async pollAllServices(): Promise<TelemetryData[]> {
    this.healthMonitor.logPollingStart(CENTRAL_CONFIG.DATA_SOURCES);

    const results: TelemetryData[] = [];

    for (const sourceUrl of CENTRAL_CONFIG.DATA_SOURCES) {
      try {
        const data = await this.pollSingleService(sourceUrl);
        if (data) {
          results.push(data);
        }
      } catch (error: any) {
        logger.error(`Непредвиденная ошибка при опросе сервиса ${sourceUrl}:`, {
          error: error.message,
          stack: error.stack
        });
      }
    }

    this.healthMonitor.logPollingComplete(results);
    return results;
  }

  private async pollSingleService(url: string): Promise<TelemetryData | null> {
    const startTime = Date.now();
    const status = this.servicesStatus.get(url)!;
    status.totalRequests++;

    try {
      logger.debug(`Опрос сервиса: ${url}`);

      const response = await this.httpClient.get(`${url}/api/telemetry`);
      const responseTime = Date.now() - startTime;

      // Обновляем статус
      status.isOnline = true;
      status.lastCheck = new Date();
      status.responseTime = responseTime;
      status.errorCount = 0;
      status.successfulRequests++;

      // Логируем получение данных
      const dataCount = Array.isArray(response.data) ? response.data.length : 1;
      this.healthMonitor.logDataReceived(url, dataCount, responseTime);

      // Отправляем статус в мониторинг
      this.healthMonitor.logServiceStatus(url, status);

      return {
        source: url,
        data: response.data,
        timestamp: new Date(),
        responseTime
      };

    } catch (error: any) {
      const responseTime = Date.now() - startTime;
      
      // Обновляем статус с ошибкой
      status.isOnline = false;
      status.lastCheck = new Date();
      status.errorCount++;
      status.lastError = this.getErrorMessage(error);

      // Детальное логирование ошибки
      this.logServiceError(url, error, responseTime);

      // Отправляем статус в мониторинг
      this.healthMonitor.logServiceStatus(url, status);

      return null;
    }
  }

  private getErrorMessage(error: any): string {
    if (error.code === 'ECONNREFUSED') return 'Connection refused';
    if (error.code === 'ETIMEDOUT') return 'Request timeout';
    if (error.code === 'ENOTFOUND') return 'Host not found';
    if (error.response?.status) return `HTTP ${error.response.status}`;
    return error.message || 'Unknown error';
  }

  private logServiceError(url: string, error: any, responseTime: number): void {
    const errorContext = {
      service: url,
      responseTime: `${responseTime}ms`,
      errorCode: error.code,
      statusCode: error.response?.status,
      errorMessage: error.message
    };

    if (error.code === 'ECONNREFUSED') {
      logger.warn(`Сервис недоступен: ${url}`, errorContext);
    } else if (error.code === 'ETIMEDOUT') {
      logger.warn(`Таймаут подключения: ${url}`, errorContext);
    } else if (error.response?.status >= 500) {
      logger.error(`Ошибка сервера: ${url}`, errorContext);
    } else if (error.response?.status >= 400) {
      logger.warn(`Ошибка клиента: ${url}`, errorContext);
    } else {
      logger.error(`Сетевая ошибка: ${url}`, errorContext);
    }
  }

  public getServicesStatus(): ServiceStatus[] {
    return Array.from(this.servicesStatus.values());
  }

  public getDetailedServicesStatus(): any {
    const services = Array.from(this.servicesStatus.values());
    
    return {
      summary: {
        totalServices: services.length,
        onlineServices: services.filter(s => s.isOnline).length,
        offlineServices: services.filter(s => !s.isOnline).length,
        totalRequests: services.reduce((sum, s) => sum + s.totalRequests, 0),
        successRate: services.length > 0 ? 
          (services.reduce((sum, s) => sum + s.successfulRequests, 0) / 
           services.reduce((sum, s) => sum + s.totalRequests, 0) * 100).toFixed(2) + '%' : '0%'
      },
      services: services,
      healthReport: this.healthMonitor.getSystemHealthReport()
    };
  }

  public getServiceHealth(serviceUrl: string): any {
    return this.healthMonitor.getServiceHealthReport(serviceUrl);
  }
}