export const CENTRAL_CONFIG = {
    PORT: process.env.PORT || 3000,
    // АДРЕСА УДАЛЕННЫХ СЕРВИСОВ - ЗАМЕНИТЕ НА РЕАЛЬНЫЕ IP/ХОСТЫ
    DATA_SOURCES: [
      process.env.SOURCE_1_URL || "http://0.0.0.0:3001", // Замените на IP второй машины
      process.env.SOURCE_2_URL || "http://0.0.0.0:3001"  // Замените на IP третьей машины
    ],
    POLLING_INTERVAL: 5000,
    REQUEST_TIMEOUT: 10000,
    RETRY_COUNT: 3,
    RETRY_DELAY: 2000
  };