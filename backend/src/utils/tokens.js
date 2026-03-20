'use strict';

const jwt = require('jsonwebtoken');

const ACCESS_SECRET = process.env.JWT_ACCESS_SECRET || 'dev_access_secret';
const REFRESH_SECRET = process.env.JWT_REFRESH_SECRET || 'dev_refresh_secret';

function generateAccessToken(userId) {
  return jwt.sign({ sub: userId }, ACCESS_SECRET, {
    expiresIn: process.env.JWT_ACCESS_EXPIRES || '15m',
  });
}

function generateRefreshToken(userId) {
  return jwt.sign({ sub: userId }, REFRESH_SECRET, {
    expiresIn: process.env.JWT_REFRESH_EXPIRES || '30d',
  });
}

function verifyRefreshToken(token) {
  return jwt.verify(token, REFRESH_SECRET);
}

module.exports = { generateAccessToken, generateRefreshToken, verifyRefreshToken };
