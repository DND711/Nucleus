'use strict';

require('dotenv').config();
require('express-async-errors');

const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const compression = require('compression');
const rateLimit = require('express-rate-limit');

const { connectMongo, connectRedis } = require('./config/database');
const { initSocket } = require('./socket');

// Routes
const authRoutes = require('./routes/auth');
const profileRoutes = require('./routes/profile');
const feedRoutes = require('./routes/feed');
const postsRoutes = require('./routes/posts');
const circlesRoutes = require('./routes/circles');
const creditsRoutes = require('./routes/credits');
const orbitRoutes = require('./routes/orbit');
const callsRoutes = require('./routes/calls');
const notificationsRoutes = require('./routes/notifications');
const searchRoutes = require('./routes/search');
const paymentsRoutes = require('./routes/payments');
const uploadRoutes = require('./routes/upload');
const socialRoutes = require('./routes/social');

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: { origin: '*', methods: ['GET', 'POST'] },
});

// ── Middleware ──────────────────────────────────────────────────────────────
app.use(helmet());
app.use(compression());
app.use(cors({ origin: '*' }));
app.use(morgan(process.env.NODE_ENV === 'production' ? 'combined' : 'dev'));
app.use(express.json({ limit: '5mb' }));
app.use(express.urlencoded({ extended: true }));

// Rate limiting
const limiter = rateLimit({ windowMs: 15 * 60 * 1000, max: 300 });
app.use('/api/', limiter);

const otpLimiter = rateLimit({ windowMs: 60 * 1000, max: 5 });
app.use('/api/auth/otp/send', otpLimiter);

// ── Routes ──────────────────────────────────────────────────────────────────
app.use('/api/auth', authRoutes);
app.use('/api/profile', profileRoutes);
app.use('/api/feed', feedRoutes);
app.use('/api/posts', postsRoutes);
app.use('/api/circles', circlesRoutes);
app.use('/api/credits', creditsRoutes);
app.use('/api/orbit', orbitRoutes);
app.use('/api/calls', callsRoutes);
app.use('/api/notifications', notificationsRoutes);
app.use('/api/search', searchRoutes);
app.use('/api/payments', paymentsRoutes);
app.use('/api/upload', uploadRoutes);
app.use('/api/social', socialRoutes);

// Health check
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    env: process.env.NODE_ENV || 'development',
    timestamp: new Date().toISOString(),
  });
});

// 404
app.use((req, res) => res.status(404).json({ error: 'Not found' }));

// Error handler
// eslint-disable-next-line no-unused-vars
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(err.status || 500).json({ error: err.message || 'Internal server error' });
});

// ── Startup ─────────────────────────────────────────────────────────────────
const PORT = process.env.PORT || 3000;

async function start() {
  await connectMongo();
  await connectRedis();
  initSocket(io);

  server.listen(PORT, '0.0.0.0', () => {
    console.log(`\n🚀 Nucleus backend running on port ${PORT}`);
    console.log(`   Health: http://localhost:${PORT}/health`);
    console.log(`   API:    http://localhost:${PORT}/api`);
    console.log(`   Env:    ${process.env.NODE_ENV || 'development'}\n`);
  });
}

start().catch((err) => {
  console.error('Failed to start:', err);
  process.exit(1);
});

module.exports = { app, server };
