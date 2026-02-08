const express = require("express");
const logger = require("./utils/logger");
const router = require("./routes/router");
const globalConfig = require("../config/globalConfig");
const replicator = require("./services/replicationService");
const { PrismaClient } = require("@prisma/client");
const prisma = new PrismaClient();
const readline = require("readline");

const app = express();
app.use("/", router);
const PORT = globalConfig.MAIN_SERVER.PORT;

app.use(express.json());

const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
});

const startReplication = (mode) => {
    setInterval(async () => {
        if (mode === "push") {
            console.log("Выталкивающая синхронизация данных...");
            await replicator.pushReplication(globalConfig);
            console.log("Выталкивающая синхронизация данных выполнена.");
        } else {
            console.log("Вытягивающая синхронизация данных...");
            await replicator.pullReplication(globalConfig);
            console.log("Вытягивающая синхронизация данных выполнена.");
        }
    }, 10000);
};

const askForReplicationMode = () => {
    rl.question("Выберите режим репликации (push/pull): ", (answer) => {
        if (answer === "push" || answer === "pull") {
            startReplication(answer);
            console.log(`Режим репликации установлен на: ${answer}`);
            rl.close();
        } else {
            console.log("Некорректный ввод. Пожалуйста, введите 'push' или 'pull'.");
            askForReplicationMode();
        }
    });
};

app.listen(PORT, async () => {
    try {
        await prisma.$connect();
        logger.info("Подключено к базе данных");
        logger.info(`Сервер работает на порту ${PORT}`);
        askForReplicationMode();
    } catch (error) {
        logger.error("Не удалось подключиться к базе данных:", error);
        process.exit(1);
    }
});
