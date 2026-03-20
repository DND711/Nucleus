'use strict';

const jwt = require('jsonwebtoken');
const mongoose = require('mongoose');

async function authMiddleware(req, res, next) {
  try {
    const header = req.headers.authorization;
    if (!header || !header.startsWith('Bearer ')) {
      return res.status(401).json({ error: 'No token provided' });
    }
    const token = header.slice(7);
    const payload = jwt.verify(token, process.env.JWT_ACCESS_SECRET || 'dev_access_secret');
    req.userId = payload.sub;

    if (mongoose.connection.readyState === 1) {
      const User = require('../models/User');
      req.user = await User.findById(payload.sub).select('-refreshToken');
      if (!req.user) return res.status(401).json({ error: 'User not found' });
    } else {
      const devStore = require('../utils/devStore');
      req.user = devStore.findUserById(payload.sub);
      if (!req.user) return res.status(401).json({ error: 'User not found' });
    }

    next();
  } catch (err) {
    if (err.name === 'TokenExpiredError') {
      return res.status(401).json({ error: 'Token expired', code: 'TOKEN_EXPIRED' });
    }
    return res.status(401).json({ error: 'Invalid token' });
  }
}

module.exports = { authMiddleware };
