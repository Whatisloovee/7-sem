const logger = require('../utils/logger');
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

exports.generateModelData = async (studentNumber) => {
    try {
        const date_time = new Date();
        const clNum = Math.floor(Math.random() * 13);
        const randomNumber = Math.floor(Math.random() * 101);

        const newData = await prisma.cl1.create({
            data: {
                date_time,
                studentNumber,
                clNum,
                randomNumber
            }
        });

        logger.info(`Сгенерированы и добавлены новые данные: ${newData.clNum}`);

        return newData;
    } catch (error) {
        logger.error('Ошибка создания данных модели:', error);
        throw error;
    }
};
