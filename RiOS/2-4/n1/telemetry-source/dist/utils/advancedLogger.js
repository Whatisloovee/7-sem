"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.logger = exports.AdvancedLogger = void 0;
const winston_1 = __importDefault(require("winston"));
require("winston-daily-rotate-file");
const path_1 = __importDefault(require("path"));
class AdvancedLogger {
    static getInstance() {
        if (!AdvancedLogger.instance) {
            const logDir = path_1.default.join(process.cwd(), 'logs');
            // Формат для консоли
            const consoleFormat = winston_1.default.format.combine(winston_1.default.format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }), winston_1.default.format.colorize(), winston_1.default.format.printf(({ timestamp, level, message, service, ...meta }) => {
                let log = `${timestamp} [${service}] ${level}: ${message}`;
                if (Object.keys(meta).length > 0) {
                    log += ` | ${JSON.stringify(meta)}`;
                }
                return log;
            }));
            // Формат для файлов
            const fileFormat = winston_1.default.format.combine(winston_1.default.format.timestamp(), winston_1.default.format.json());
            AdvancedLogger.instance = winston_1.default.createLogger({
                level: process.env.LOG_LEVEL || 'info',
                defaultMeta: {
                    service: process.env.SERVICE_NAME || 'unknown-service',
                    host: process.env.HOST || 'localhost'
                },
                transports: [
                    // Консоль
                    new winston_1.default.transports.Console({
                        format: consoleFormat
                    }),
                    // Файл всех логов
                    new winston_1.default.transports.DailyRotateFile({
                        filename: path_1.default.join(logDir, 'combined-%DATE%.log'),
                        datePattern: 'YYYY-MM-DD',
                        zippedArchive: true,
                        maxSize: '20m',
                        maxFiles: '14d',
                        format: fileFormat
                    }),
                    // Файл ошибок
                    new winston_1.default.transports.DailyRotateFile({
                        filename: path_1.default.join(logDir, 'error-%DATE%.log'),
                        datePattern: 'YYYY-MM-DD',
                        level: 'error',
                        zippedArchive: true,
                        maxSize: '20m',
                        maxFiles: '30d',
                        format: fileFormat
                    }),
                    // Файл опросов телеметрии
                    new winston_1.default.transports.DailyRotateFile({
                        filename: path_1.default.join(logDir, 'telemetry-%DATE%.log'),
                        datePattern: 'YYYY-MM-DD',
                        level: 'polling',
                        zippedArchive: true,
                        maxSize: '20m',
                        maxFiles: '7d',
                        format: fileFormat
                    })
                ]
            });
            // Добавляем кастомный уровень для опросов
            AdvancedLogger.instance.addLevels({
                polling: 2, // Выше info, ниже warn
            });
        }
        return AdvancedLogger.instance;
    }
}
exports.AdvancedLogger = AdvancedLogger;
exports.logger = AdvancedLogger.getInstance();
