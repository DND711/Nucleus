'use strict';

const express = require('express');
const router = express.Router();
const { authMiddleware } = require('../middleware/auth');

const TURN_CONFIG = {
  urls: [process.env.TURN_URL || 'turn:turn.nucleus.app:3478'],
  username: process.env.TURN_USERNAME || 'nucleus',
  credential: process.env.TURN_CREDENTIAL || 'dev_turn_secret',
};

// GET /calls/ice-servers — returns STUN/TURN config for WebRTC
router.get('/ice-servers', authMiddleware, (req, res) => {
  res.json({
    iceServers: [
      { urls: 'stun:stun.l.google.com:19302' },
      TURN_CONFIG,
    ],
  });
});

// POST /calls/initiate — signal a call to another user (relayed via Socket.io in production)
router.post('/initiate', authMiddleware, async (req, res) => {
  const { targetUserId, callType = 'voice' } = req.body;
  if (!targetUserId) return res.status(400).json({ error: 'targetUserId required' });

  const creditsPerMin = callType === 'video' ? 5 : 2;
  const callId = require('crypto').randomUUID();

  res.json({
    callId,
    callType,
    creditsPerMin,
    iceServers: [
      { urls: 'stun:stun.l.google.com:19302' },
      TURN_CONFIG,
    ],
  });
});

// POST /calls/:callId/end
router.post('/:callId/end', authMiddleware, (req, res) => {
  const { durationSec, creditsDeducted } = req.body;
  // In production: reconcile credits, save call log
  res.json({ message: 'Call ended', durationSec, creditsDeducted });
});

module.exports = router;
