"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const cors_1 = __importDefault(require("cors"));
const helmet_1 = __importDefault(require("helmet"));
const EnhancedPollingService_1 = require("./services/EnhancedPollingService");
const config_1 = require("./config");
const logger_1 = require("./utils/logger");
class CentralService {
    constructor() {
        this.app = (0, express_1.default)();
        this.setupMiddleware();
        this.setupRoutes();
        this.pollingService = new EnhancedPollingService_1.CentralPollingService();
    }
    setupMiddleware() {
        this.app.use((0, helmet_1.default)());
        this.app.use((0, cors_1.default)({
            origin: process.env.CORS_ORIGIN || "*"
        }));
        this.app.use(express_1.default.json());
    }
    setupRoutes() {
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
            }
            catch (error) {
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
                sources: config_1.CENTRAL_CONFIG.DATA_SOURCES
            });
        });
        this.app.get('/api/services/status/detailed', (req, res) => {
            try {
                const detailedStatus = this.pollingService.getDetailedServicesStatus();
                logger_1.logger.info('Запрос детального статуса сервисов', {
                    client: req.ip,
                    userAgent: req.get('User-Agent')
                });
                res.json({
                    success: true,
                    data: detailedStatus,
                    timestamp: new Date().toISOString()
                });
            }
            catch (error) {
                logger_1.logger.error('Ошибка получения детального статуса', {
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
                logger_1.logger.debug('Запрос здоровья сервиса', {
                    service: serviceUrl,
                    client: req.ip
                });
                res.json({
                    success: true,
                    data: health,
                    timestamp: new Date().toISOString()
                });
            }
            catch (error) {
                logger_1.logger.error('Ошибка получения здоровья сервиса', {
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
                logger_1.logger.debug('Запрос статистики системы', {
                    client: req.ip
                });
                res.json({
                    success: true,
                    data: stats
                });
            }
            catch (error) {
                logger_1.logger.error('Ошибка получения статистики системы', {
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
            logger_1.logger.warn('Попытка доступа к логам системы', {
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
    async start() {
        // Запускаем фоновый опрос
        this.pollingService.startBackgroundPolling();
        this.app.listen(config_1.CENTRAL_CONFIG.PORT, () => {
            logger_1.logger.info('🚀 ЦЕНТРАЛЬНЫЙ СЕРВИС ЗАПУЩЕН', {
                port: config_1.CENTRAL_CONFIG.PORT,
                sources: config_1.CENTRAL_CONFIG.DATA_SOURCES,
                interval: config_1.CENTRAL_CONFIG.POLLING_INTERVAL
            });
        });
    }
}
// Запуск сервиса
const service = new CentralService();
service.start().catch(console.error);
