"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.COMMON_CONFIG = void 0;
exports.COMMON_CONFIG = {
    CORS_ORIGIN: process.env.CORS_ORIGIN || "*",
    LOG_LEVEL: process.env.LOG_LEVEL || "info",
    REQUEST_TIMEOUT: 10000
};
