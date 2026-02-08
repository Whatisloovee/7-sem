import winston from 'winston';
import DailyRotateFile from 'winston-daily-rotate-file';
import path from 'path';

// Создаем кастомные уровни для логирования
const customLevels = {
  levels: {
    error: 0,
    warn: 1,
    polling: 2,  // Кастомный уровень для опросов
    info: 3,
    http: 4,
    verbose: 5,
    debug: 6,
    silly: 7
  },
  colors: {
    error: 'red',
    warn: 'yellow', 
    polling: 'cyan',
    info: 'green',
    http: 'magenta',
    verbose: 'blue',
    debug: 'white',
    silly: 'gray'
  }
};

export class AdvancedLogger {
  private static instance: winston.Logger;

  static getInstance(): winston.Logger {
    if (!AdvancedLogger.instance) {
      const logDir = path.join(process.cwd(), 'logs');

      // Регистрируем цвета
      winston.addColors(customLevels.colors);

      // Формат для консоли
      const consoleFormat = winston.format.combine(
        winston.format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }),
        winston.format.colorize(),
        winston.format.printf(({ timestamp, level, message, service, ...meta }) => {
          let log = `${timestamp} [${service}] ${level}: ${message}`;
          if (Object.keys(meta).length > 0) {
            log += ` | ${JSON.stringify(meta)}`;
          }
          return log;
        })
      );

      // Формат для файлов
      const fileFormat = winston.format.combine(
        winston.format.timestamp(),
        winston.format.json()
      );

      AdvancedLogger.instance = winston.createLogger({
        level: process.env.LOG_LEVEL || 'info',
        levels: customLevels.levels,
        defaultMeta: { 
          service: process.env.SERVICE_NAME || 'unknown-service',
          host: process.env.HOST || 'localhost'
        },
        transports: [
          // Консоль
          new winston.transports.Console({
            format: consoleFormat
          }),

          // Файл всех логов
          new DailyRotateFile({
            filename: path.join(logDir, 'combined-%DATE%.log'),
            datePattern: 'YYYY-MM-DD',
            zippedArchive: true,
            maxSize: '20m',
            maxFiles: '14d',
            format: fileFormat
          }),

          // Файл ошибок
          new DailyRotateFile({
            filename: path.join(logDir, 'error-%DATE%.log'),
            datePattern: 'YYYY-MM-DD',
            level: 'error',
            zippedArchive: true,
            maxSize: '20m',
            maxFiles: '30d',
            format: fileFormat
          }),

          // Файл опросов телеметрии
          new DailyRotateFile({
            filename: path.join(logDir, 'telemetry-%DATE%.log'),
            datePattern: 'YYYY-MM-DD',
            level: 'polling',
            zippedArchive: true,
            maxSize: '20m',
            maxFiles: '7d',
            format: fileFormat
          })
        ],

        // Обработка необработанных исключений
        exceptionHandlers: [
          new winston.transports.Console({
            format: consoleFormat
          }),
          new DailyRotateFile({
            filename: path.join(logDir, 'exceptions-%DATE%.log'),
            datePattern: 'YYYY-MM-DD',
            zippedArchive: true,
            maxSize: '20m',
            maxFiles: '30d'
          })
        ],

        // Обработка необработанных промисов
        rejectionHandlers: [
          new winston.transports.Console({
            format: consoleFormat
          }),
          new DailyRotateFile({
            filename: path.join(logDir, 'rejections-%DATE%.log'),
            datePattern: 'YYYY-MM-DD',
            zippedArchive: true,
            maxSize: '20m',
            maxFiles: '30d'
          })
        ]
      });
    }

    return AdvancedLogger.instance;
  }
}

export const logger = AdvancedLogger.getInstance();