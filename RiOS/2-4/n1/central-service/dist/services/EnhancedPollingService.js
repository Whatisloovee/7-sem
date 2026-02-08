"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.CentralPollingService = void 0;
const axios_1 = __importDefault(require("axios"));
const config_1 = require("../config");
const HealthMonitor_1 = require("./HealthMonitor");
const advancedLogger_1 = require("../utils/advancedLogger");
class CentralPollingService {
    constructor() {
        this.servicesStatus = new Map();
        this.isPolling = false;
        this.httpClient = axios_1.default.create({
            timeout: config_1.CENTRAL_CONFIG.REQUEST_TIMEOUT
        });
        this.healthMonitor = new HealthMonitor_1.HealthMonitor();
        this.initializeServicesStatus();
        // Логирование инициализации
        advancedLogger_1.logger.info('Сервис опроса инициализирован', {
            sources: config_1.CENTRAL_CONFIG.DATA_SOURCES,
            interval: config_1.CENTRAL_CONFIG.POLLING_INTERVAL,
            timeout: config_1.CENTRAL_CONFIG.REQUEST_TIMEOUT
        });
    }
    initializeServicesStatus() {
        config_1.CENTRAL_CONFIG.DATA_SOURCES.forEach(url => {
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
    startBackgroundPolling() {
        if (this.isPolling) {
            advancedLogger_1.logger.warn('Фоновый опрос уже запущен');
            return;
        }
        this.isPolling = true;
        advancedLogger_1.logger.info('Запуск фонового опроса сервисов', {
            interval: config_1.CENTRAL_CONFIG.POLLING_INTERVAL,
            sourceCount: config_1.CENTRAL_CONFIG.DATA_SOURCES.length
        });
        setInterval(() => {
            this.pollAllServices().catch(error => {
                advancedLogger_1.logger.error('Критическая ошибка фонового опроса:', {
                    error: error.message,
                    stack: error.stack
                });
            });
        }, config_1.CENTRAL_CONFIG.POLLING_INTERVAL);
        // Немедленный первый опрос
        setTimeout(() => {
            this.pollAllServices().catch(console.error);
        }, 1000);
    }
    async forcePoll() {
        advancedLogger_1.logger.info('Принудительный опрос запущен');
        return await this.pollAllServices();
    }
    async pollAllServices() {
        this.healthMonitor.logPollingStart(config_1.CENTRAL_CONFIG.DATA_SOURCES);
        const results = [];
        for (const sourceUrl of config_1.CENTRAL_CONFIG.DATA_SOURCES) {
            try {
                const data = await this.pollSingleService(sourceUrl);
                if (data) {
                    results.push(data);
                }
            }
            catch (error) {
                advancedLogger_1.logger.error(`Непредвиденная ошибка при опросе сервиса ${sourceUrl}:`, {
                    error: error.message,
                    stack: error.stack
                });
            }
        }
        this.healthMonitor.logPollingComplete(results);
        return results;
    }
    async pollSingleService(url) {
        const startTime = Date.now();
        const status = this.servicesStatus.get(url);
        status.totalRequests++;
        try {
            advancedLogger_1.logger.debug(`Опрос сервиса: ${url}`);
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
        }
        catch (error) {
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
    getErrorMessage(error) {
        if (error.code === 'ECONNREFUSED')
            return 'Connection refused';
        if (error.code === 'ETIMEDOUT')
            return 'Request timeout';
        if (error.code === 'ENOTFOUND')
            return 'Host not found';
        if (error.response?.status)
            return `HTTP ${error.response.status}`;
        return error.message || 'Unknown error';
    }
    logServiceError(url, error, responseTime) {
        const errorContext = {
            service: url,
            responseTime: `${responseTime}ms`,
            errorCode: error.code,
            statusCode: error.response?.status,
            errorMessage: error.message
        };
        if (error.code === 'ECONNREFUSED') {
            advancedLogger_1.logger.warn(`Сервис недоступен: ${url}`, errorContext);
        }
        else if (error.code === 'ETIMEDOUT') {
            advancedLogger_1.logger.warn(`Таймаут подключения: ${url}`, errorContext);
        }
        else if (error.response?.status >= 500) {
            advancedLogger_1.logger.error(`Ошибка сервера: ${url}`, errorContext);
        }
        else if (error.response?.status >= 400) {
            advancedLogger_1.logger.warn(`Ошибка клиента: ${url}`, errorContext);
        }
        else {
            advancedLogger_1.logger.error(`Сетевая ошибка: ${url}`, errorContext);
        }
    }
    getServicesStatus() {
        return Array.from(this.servicesStatus.values());
    }
    getDetailedServicesStatus() {
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
    getServiceHealth(serviceUrl) {
        return this.healthMonitor.getServiceHealthReport(serviceUrl);
    }
}
exports.CentralPollingService = CentralPollingService;
