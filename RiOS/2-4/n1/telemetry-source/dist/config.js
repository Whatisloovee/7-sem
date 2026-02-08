"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.SOURCE_CONFIG = void 0;
exports.SOURCE_CONFIG = {
    PORT: Number(process.env.PORT) || 3001,
    SOURCE_NAME: process.env.SOURCE_NAME || 'unknown-source',
    HOST: process.env.HOST || '0.0.0.0' // Слушаем все интерфейсы
};
