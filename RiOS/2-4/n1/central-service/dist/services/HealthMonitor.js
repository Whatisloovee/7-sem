"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.HealthMonitor = void 0;
const advancedLogger_1 = require("../utils/advancedLogger");
class HealthMonitor {
    constructor() {
        this.serviceHistory = new Map();
        this.MAX_HISTORY = 100;
        advancedLogger_1.logger.info('Мониторинг состояния сервисов инициализирован');
    }
    logServiceStatus(serviceUrl, status) {
        // Сохраняем историю
        if (!this.serviceHistory.has(serviceUrl)) {
            this.serviceHistory.set(serviceUrl, []);
        }
        const history = this.serviceHistory.get(serviceUrl);
        history.push({ ...status });
        // Ограничиваем размер истории
        if (history.length > this.MAX_HISTORY) {
            history.shift();
        }
        // Логируем изменение состояния
        this.logStatusChange(serviceUrl, status);
    }
    logStatusChange(serviceUrl, status) {
        const level = status.isOnline ? 'info' : 'warn';
        advancedLogger_1.logger.log(level, `Состояние сервиса изменено`, {
            service: serviceUrl,
            online: status.isOnline,
            responseTime: status.responseTime,
            errorCount: status.errorCount,
            lastCheck: status.lastCheck.toISOString()
        });
        // Детальное логирование для опросов
        if (status.isOnline) {
            advancedLogger_1.logger.log('polling', `Успешный опрос сервиса`, {
                service: serviceUrl,
                responseTime: status.responseTime,
                timestamp: new Date().toISOString()
            });
        }
        else {
            advancedLogger_1.logger.error(`Сервис недоступен`, {
                service: serviceUrl,
                lastError: status.lastError,
                consecutiveErrors: status.errorCount,
                lastAttempt: status.lastCheck.toISOString()
            });
        }
    }
    getServiceHealthReport(serviceUrl) {
        const history = this.serviceHistory.get(serviceUrl) || [];
        const last24h = history.filter(s => Date.now() - s.lastCheck.getTime() < 24 * 60 * 60 * 1000);
        if (last24h.length === 0) {
            return { available: false, message: 'Нет данных за последние 24 часа' };
        }
        const onlineCount = last24h.filter(s => s.isOnline).length;
        const availability = (onlineCount / last24h.length) * 100;
        const avgResponseTime = last24h
            .filter(s => s.isOnline)
            .reduce((sum, s) => sum + s.responseTime, 0) / onlineCount || 0;
        return {
            available: true,
            availability: `${availability.toFixed(2)}%`,
            averageResponseTime: `${avgResponseTime.toFixed(2)}ms`,
            totalChecks: last24h.length,
            successfulChecks: onlineCount,
            failedChecks: last24h.length - onlineCount,
            lastStatus: history[history.length - 1] || null
        };
    }
    getSystemHealthReport() {
        const reports = {};
        let totalAvailability = 0;
        let serviceCount = 0;
        for (const [serviceUrl] of this.serviceHistory) {
            const report = this.getServiceHealthReport(serviceUrl);
            reports[serviceUrl] = report;
            if (report.available) {
                totalAvailability += parseFloat(report.availability);
                serviceCount++;
            }
        }
        const systemAvailability = serviceCount > 0 ? totalAvailability / serviceCount : 0;
        return {
            system: {
                overallAvailability: `${systemAvailability.toFixed(2)}%`,
                monitoredServices: serviceCount,
                status: systemAvailability > 95 ? 'HEALTHY' : systemAvailability > 80 ? 'DEGRADED' : 'CRITICAL',
                timestamp: new Date().toISOString()
            },
            services: reports
        };
    }
    logPollingStart(sources) {
        advancedLogger_1.logger.log('polling', '🚀 Начало цикла опроса', {
            sourceCount: sources.length,
            sources: sources,
            timestamp: new Date().toISOString()
        });
    }
    logPollingComplete(results) {
        const successful = results.filter(r => r !== null).length;
        const failed = results.length - successful;
        advancedLogger_1.logger.log('polling', '✅ Цикл опроса завершен', {
            total: results.length,
            successful,
            failed,
            successRate: `${((successful / results.length) * 100).toFixed(1)}%`,
            timestamp: new Date().toISOString()
        });
    }
    logDataReceived(serviceUrl, dataCount, responseTime) {
        advancedLogger_1.logger.log('polling', '📊 Данные телеметрии получены', {
            service: serviceUrl,
            dataPoints: dataCount,
            responseTime: `${responseTime}ms`,
            dataRate: `${(dataCount / (responseTime / 1000)).toFixed(2)} points/sec`,
            timestamp: new Date().toISOString()
        });
    }
}
exports.HealthMonitor = HealthMonitor;
