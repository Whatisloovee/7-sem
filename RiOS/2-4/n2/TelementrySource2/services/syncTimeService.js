const axios = require('axios');
const logger = require('../utils/logger');

exports.syncTime = async (config) => {
    try {
        const serverResponse = await axios.get(`${config.MAIN_SERVER.ADDRESS}/getCurrTime`);
        
        console.log(`${serverResponse.data}`);
        const localTime = new Date();
        console.log(`${serverResponse.data} ${localTime}`)
        const diffMilliseconds = localTime - new Date(serverResponse.data);

        console.log(`${serverResponse.data} ${localTime} ${diffMilliseconds}`)

        logger.info(`Временная коррекция для сервера ${config.MAIN_SERVER.ADDRESS} => ${diffMilliseconds}`)
    } catch (error) {
        logger.error(error)
        throw new Error('Не удалось синхронизировать время: ', error);
    }
};