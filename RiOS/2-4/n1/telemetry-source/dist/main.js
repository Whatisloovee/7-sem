"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const cors_1 = __importDefault(require("cors"));
const helmet_1 = __importDefault(require("helmet"));
const TelemetryGenerator_1 = require("./services/TelemetryGenerator");
const config_1 = require("./config");
const logger_1 = require("./utils/logger");
class TelemetrySource {
    constructor() {
        this.app = (0, express_1.default)();
        this.telemetryGenerator = new TelemetryGenerator_1.TelemetryGenerator(config_1.SOURCE_CONFIG.SOURCE_NAME);
        this.setupMiddleware();
        this.setupRoutes();
    }
    setupMiddleware() {
        this.app.use((0, helmet_1.default)());
        this.app.use((0, cors_1.default)({
            origin: process.env.CORS_ORIGIN || "*"
        }));
        this.app.use(express_1.default.json());
    }
    setupRoutes() {
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
            }
            catch (error) {
                logger_1.logger.error('Ошибка генерации телеметрии:', error);
                res.status(500).json({
                    error: 'Service temporarily unavailable',
                    source: config_1.SOURCE_CONFIG.SOURCE_NAME
                });
            }
        });
        // Статус сервиса
        this.app.get('/api/status', (req, res) => {
            res.json({
                status: 'operational',
                source: config_1.SOURCE_CONFIG.SOURCE_NAME,
                uptime: process.uptime(),
                timestamp: new Date().toISOString()
            });
        });
        // Health check
        this.app.get('/health', (req, res) => {
            res.json({
                status: 'healthy',
                service: config_1.SOURCE_CONFIG.SOURCE_NAME,
                timestamp: new Date().toISOString()
            });
        });
        // Информация о сервисе
        this.app.get('/api/info', (req, res) => {
            res.json({
                name: config_1.SOURCE_CONFIG.SOURCE_NAME,
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
    start() {
        this.app.listen(config_1.SOURCE_CONFIG.PORT, config_1.SOURCE_CONFIG.HOST, () => {
            logger_1.logger.info(`📡 ИСТОЧНИК ДАННЫХ ЗАПУЩЕН`, {
                name: config_1.SOURCE_CONFIG.SOURCE_NAME,
                host: config_1.SOURCE_CONFIG.HOST,
                port: config_1.SOURCE_CONFIG.PORT
            });
        });
    }
}
// Запуск сервиса-источника
const source = new TelemetrySource();
source.start();
