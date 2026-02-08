const express = require('express');
const router = express.Router();
const controller = require('../controller/controller');

router.get('/getCurrTime', controller.getCurrTime);

module.exports = router;