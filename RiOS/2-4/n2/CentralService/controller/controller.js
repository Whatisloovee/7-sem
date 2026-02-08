const logger = require('../utils/logger');

exports.getCurrTime = async (req, res) => {
    try {
        const dateTime = new Date();
        console.log(`${dateTime}`)
        res.status(200).json(dateTime);
    } catch (error) {
        logger.error(`Не удалось получить текущее время: ${error.message}`);
        res.status(500).json({ error: 'Не удалось получить текущее время' });
    }
};