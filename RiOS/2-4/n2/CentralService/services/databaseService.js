const logger = require('../utils/logger');
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

exports.InsertDataIntoDB = async (dataArray) => {
    try {
        for (const data of dataArray) {
            const existingData = await prisma.cl1.findFirst({
                where: {
                    studentNumber: data.studentNumber,
                    clNum: data.clNum,
                    randomNumber: data.randomNumber
                }
            });

            if (!existingData) {
                const newData = await prisma.cl1.create({
                    data: {
                        date_time: new Date(),
                        studentNumber: data.studentNumber,
                        clNum: data.clNum,
                        randomNumber: data.randomNumber
                    }
                });
                logger.info(`Сгенерированы и добавлены новые данные: ${newData.clNum}`);
            } else {
                logger.info(`Данные уже существуют: ${existingData.clNum}`);
            }
        }
    } catch (error) {
        logger.error('Ошибка создания данных модели:', error);
        throw error;
    }
};

exports.getAllDataFromDB = async () => {
    try {
        const allData = await prisma.cl1.findMany();

        if (!allData || allData.length === 0) {
            logger.error('В базе данных не найдено данных');
            throw new Error(errorMessage);
        }

        return allData;
    } catch (error) {
        throw error;
    }
};

