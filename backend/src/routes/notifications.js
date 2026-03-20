'use strict';

const express = require('express');
const router = express.Router();
const Notification = require('../models/Notification');
const { authMiddleware } = require('../middleware/auth');

// GET /notifications
router.get('/', authMiddleware, async (req, res) => {
  const limit = Math.min(parseInt(req.query.limit) || 20, 50);
  const cursor = req.query.cursor;

  const query = { recipient: req.userId };
  if (cursor) query.createdAt = { $lt: new Date(cursor) };

  const notifications = await Notification.find(query)
    .sort({ createdAt: -1 })
    .limit(limit + 1)
    .populate('actor', 'displayName username avatarUrl')
    .lean();

  const hasMore = notifications.length > limit;
  if (hasMore) notifications.pop();

  const nextCursor = hasMore && notifications.length > 0
    ? notifications[notifications.length - 1].createdAt.toISOString()
    : null;

  res.json({ notifications, nextCursor, hasMore });
});

// POST /notifications/read-all
router.post('/read-all', authMiddleware, async (req, res) => {
  await Notification.updateMany({ recipient: req.userId, isRead: false }, { isRead: true });
  res.json({ message: 'All marked read' });
});

// PATCH /notifications/:id/read
router.patch('/:id/read', authMiddleware, async (req, res) => {
  await Notification.findOneAndUpdate(
    { _id: req.params.id, recipient: req.userId },
    { isRead: true },
  );
  res.json({ message: 'Marked read' });
});

// POST /notifications/fcm-token — register device push token
router.post('/fcm-token', authMiddleware, async (req, res) => {
  const { token } = req.body;
  if (!token) return res.status(400).json({ error: 'Token required' });
  const User = require('../models/User');
  await User.findByIdAndUpdate(req.userId, { $addToSet: { fcmTokens: token } });
  res.json({ message: 'FCM token registered' });
});

module.exports = router;
