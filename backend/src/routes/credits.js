'use strict';

const express = require('express');
const router = express.Router();
const User = require('../models/User');
const { authMiddleware } = require('../middleware/auth');
const { getRedis } = require('../config/database');

// GET /credits — balance
router.get('/', authMiddleware, (req, res) => {
  res.json({ credits: req.user.credits });
});

// POST /credits/daily — claim daily credits
router.post('/daily', authMiddleware, async (req, res) => {
  const user = req.user;
  const now = new Date();
  const last = user.lastDailyCreditAt;

  if (last) {
    const hoursSince = (now - last) / 1000 / 3600;
    if (hoursSince < 20) {
      const nextAt = new Date(last.getTime() + 20 * 3600 * 1000);
      return res.status(429).json({ error: 'Already claimed today', nextAvailableAt: nextAt });
    }
  }

  const amount = parseInt(process.env.DAILY_CREDIT_AMOUNT) || 50;
  const updated = await User.findByIdAndUpdate(
    user._id,
    { $inc: { credits: amount }, lastDailyCreditAt: now },
    { new: true },
  );
  res.json({ credits: updated.credits, awarded: amount });
});

// POST /credits/deduct — deduct credits (called internally by calls)
router.post('/deduct', authMiddleware, async (req, res) => {
  const { amount } = req.body;
  if (!amount || amount < 0) return res.status(400).json({ error: 'Invalid amount' });

  const user = await User.findById(req.userId);
  if (user.credits < amount) return res.status(402).json({ error: 'Insufficient credits' });

  const updated = await User.findByIdAndUpdate(
    req.userId,
    { $inc: { credits: -amount } },
    { new: true },
  );
  res.json({ credits: updated.credits });
});

// GET /credits/packages — purchasable packs
router.get('/packages', authMiddleware, (req, res) => {
  res.json({
    packages: [
      { id: 'credits_100', credits: 100, priceInr: 49, label: 'Starter' },
      { id: 'credits_500', credits: 500, priceInr: 199, label: 'Popular', badge: 'BEST VALUE' },
      { id: 'credits_1200', credits: 1200, priceInr: 399, label: 'Pro' },
      { id: 'credits_3000', credits: 3000, priceInr: 899, label: 'Mega' },
    ],
  });
});

module.exports = router;
