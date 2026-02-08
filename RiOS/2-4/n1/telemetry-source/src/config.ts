export const SOURCE_CONFIG = {
    PORT: Number(process.env.PORT) || 3001,
    SOURCE_NAME: process.env.SOURCE_NAME || 'unknown-source',
    HOST: process.env.HOST || '0.0.0.0' // Слушаем все интерфейсы
  };