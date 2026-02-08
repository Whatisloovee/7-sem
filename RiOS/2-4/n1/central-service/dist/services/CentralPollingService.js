"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.CentralPollingService = void 0;
const axios_1 = __importDefault(require("axios"));
const config_1 = require("../config");
const logger_1 = require("../utils/logger");
class CentralPollingService {
    constructor() {
        this.servicesStatus = new Map();
        this.isPolling = false;
        this.httpClient = axios_1.default.create({
            timeout: config_1.CENTRAL_CONFIG.REQUEST_TIMEOUT
        });
        this.initializeServicesStatus();
    }
    initializeServicesStatus() {
        config_1.CENTRAL_CONFIG.DATA_SOURCES.forEach(url => {
            this.servicesStatus.set(url, {
                url,
                isOnline: false,
                lastCheck: new Date(0),
                responseTime: 0,
                errorCount: 0
            });
        });
    }
    startBackgroundPolling() {
        if (this.isPolling)
            return;
        this.isPolling = true;
        setInterval(() => {
            this.pollAllServices().catch(error => {
                logger_1.logger.error('Ошибка фонового опроса:', error);
            });
        }, config_1.CENTRAL_CONFIG.POLLING_INTERVAL);
        logger_1.logger.info('Фоновый опрос запущен');
    }
    async forcePoll() {
        return await this.pollAllServices();
    }
    async pollAllServices() {
        const results = [];
        for (const sourceUrl of config_1.CENTRAL_CONFIG.DATA_SOURCES) {
            try {
                const data = await this.pollSingleService(sourceUrl);
                if (data) {
                    results.push(data);
                }
            }
            catch (error) {
                logger_1.logger.error(`Ошибка опроса сервиса ${sourceUrl}:`, error);
            }
        }
        return results;
    }
    async pollSingleService(url) {
        const startTime = Date.now();
        const status = this.servicesStatus.get(url);
        try {
            const response = await this.httpClient.get(`${url}/api/telemetry`);
            const responseTime = Date.now() - startTime;
            // Обновляем статус
            status.isOnline = true;
            status.lastCheck = new Date();
            status.responseTime = responseTime;
            status.errorCount = 0;
            logger_1.logger.info(`✅ Сервис ${url} отвечает`, { responseTime });
            return {
                source: url,
                data: response.data,
                timestamp: new Date()
            };
        }
        catch (error) {
            // Обновляем статус с ошибкой
            status.isOnline = false;
            status.lastCheck = new Date();
            status.errorCount++;
            status.lastError = error.message;
            logger_1.logger.warn(`❌ Сервис ${url} недоступен`, {
                error: error.message,
                errorCount: status.errorCount
            });
            return null;
        }
    }
    getServicesStatus() {
        return Array.from(this.servicesStatus.values());
    }
}
exports.CentralPollingService = CentralPollingService;
