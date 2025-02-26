const express = require('express');
const router = express.Router();
const { login } = require('../controllers/authController');

// POST route to handle login
router.post('/login', login);

module.exports = router;
