const databaseService = require('../services/databaseService');
const logger = require('../utils/logger');



exports.pushReplicationController = async (req, res) => {
    try {
    
        const modelData = req.body;

        if (!modelData) {
            throw new Error('Неверный формат данных');
        }

      
        await databaseService.InsertDataIntoDB(modelData);

        logger.info('Данные успешно добавлены в базу данных');

        res.status(200).json({ message: 'Данные успешно добавлены в базу данных' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.pullReplicationController = async (req, res) => {
    try {
        const allData = await databaseService.getAllDataFromDB();

        res.status(200).json(allData);
    } catch (error) {
        logger.error(`Не удалось получить данные репликации.: ${error.message}`);
        
        res.status(500).json({ error: 'Не удалось получить данные репликации.' });
    }
};

