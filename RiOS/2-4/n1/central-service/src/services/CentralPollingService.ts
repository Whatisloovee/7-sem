import axios, { AxiosInstance } from 'axios';
import { CENTRAL_CONFIG } from '../config';
import { logger } from '../utils/logger';

export interface ServiceStatus {
  url: string;
  isOnline: boolean;
  lastCheck: Date;
  responseTime: number;
  errorCount: number;
  lastError?: string;
}

export interface TelemetryData {
  source: string;
  data: any[];
  timestamp: Date;
}

export class CentralPollingService {
  private httpClient: AxiosInstance;
  private servicesStatus: Map<string, ServiceStatus> = new Map();
  private isPolling: boolean = false;

  constructor() {
    this.httpClient = axios.create({
      timeout: CENTRAL_CONFIG.REQUEST_TIMEOUT
    });

    this.initializeServicesStatus();
  }

  private initializeServicesStatus(): void {
    CENTRAL_CONFIG.DATA_SOURCES.forEach(url => {
      this.servicesStatus.set(url, {
        url,
        isOnline: false,
        lastCheck: new Date(0),
        responseTime: 0,
        errorCount: 0
      });
    });
  }

  public startBackgroundPolling(): void {
    if (this.isPolling) return;

    this.isPolling = true;
    setInterval(() => {
      this.pollAllServices().catch(error => {
        logger.error('Ошибка фонового опроса:', error);
      });
    }, CENTRAL_CONFIG.POLLING_INTERVAL);

    logger.info('Фоновый опрос запущен');
  }

  public async forcePoll(): Promise<TelemetryData[]> {
    return await this.pollAllServices();
  }

  private async pollAllServices(): Promise<TelemetryData[]> {
    const results: TelemetryData[] = [];

    for (const sourceUrl of CENTRAL_CONFIG.DATA_SOURCES) {
      try {
        const data = await this.pollSingleService(sourceUrl);
        if (data) {
          results.push(data);
        }
      } catch (error) {
        logger.error(`Ошибка опроса сервиса ${sourceUrl}:`, error);
      }
    }

    return results;
  }

  private async pollSingleService(url: string): Promise<TelemetryData | null> {
    const startTime = Date.now();
    const status = this.servicesStatus.get(url)!;

    try {
      const response = await this.httpClient.get(`${url}/api/telemetry`);
      const responseTime = Date.now() - startTime;

      // Обновляем статус
      status.isOnline = true;
      status.lastCheck = new Date();
      status.responseTime = responseTime;
      status.errorCount = 0;

      logger.info(`✅ Сервис ${url} отвечает`, { responseTime });

      return {
        source: url,
        data: response.data,
        timestamp: new Date()
      };

    } catch (error: any) {
      // Обновляем статус с ошибкой
      status.isOnline = false;
      status.lastCheck = new Date();
      status.errorCount++;
      status.lastError = error.message;

      logger.warn(`❌ Сервис ${url} недоступен`, {
        error: error.message,
        errorCount: status.errorCount
      });
      return null;
    }
  }

  public getServicesStatus(): ServiceStatus[] {
    return Array.from(this.servicesStatus.values());
  }
}