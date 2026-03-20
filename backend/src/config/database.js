'use strict';

const mongoose = require('mongoose');

let redisClient = null;

async function connectMongo() {
  const uri = process.env.MONGODB_URI || 'mongodb://localhost:27017/nucleus';
  try {
    await mongoose.connect(uri, { serverSelectionTimeoutMS: 5000 });
    console.log('✅ MongoDB connected');
  } catch (err) {
    console.warn('⚠️  MongoDB unavailable — running without DB:', err.message);
  }
}

async function connectRedis() {
  try {
    const { createClient } = require('redis');
    redisClient = createClient({
      url: process.env.REDIS_URL || 'redis://localhost:6379',
      socket: { reconnectStrategy: false, connectTimeout: 3000 },
    });
    redisClient.on('error', () => {}); // suppress repeated errors
    await redisClient.connect();
    console.log('✅ Redis connected');
  } catch (err) {
    console.warn('⚠️  Redis unavailable — running without cache:', err.message);
    redisClient = null;
  }
}

function getRedis() {
  return redisClient;
}

module.exports = { connectMongo, connectRedis, getRedis };
