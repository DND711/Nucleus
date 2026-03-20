'use strict';

const express = require('express');
const router = express.Router();
const User = require('../models/User');
const { authMiddleware } = require('../middleware/auth');

// GET /orbit/discover — potential matches
router.get('/discover', authMiddleware, async (req, res) => {
  const me = req.user;
  if (!me.orbitEnabled || !me.orbitVerified) {
    return res.status(403).json({ error: 'Orbit not enabled or verified' });
  }

  // Basic discovery: find other verified orbit users excluding self
  const users = await User.find({
    _id: { $ne: me._id },
    orbitEnabled: true,
    orbitVerified: true,
    isActive: true,
  })
    .select('displayName username avatarUrl orbitBio orbitPhotos orbitGender vibes isVerified')
    .limit(20)
    .lean();

  // Add mock compatibility score
  const candidates = users.map(u => ({ ...u, compatibilityScore: Math.floor(Math.random() * 40) + 60 }));
  res.json({ candidates });
});

// POST /orbit/setup — setup orbit profile
router.post('/setup', authMiddleware, async (req, res) => {
  const { orbitGender, orbitInterestedIn, orbitAgeRange, orbitBio, orbitPhotos } = req.body;
  const updates = { orbitEnabled: true };
  if (orbitGender) updates.orbitGender = orbitGender;
  if (orbitInterestedIn) updates.orbitInterestedIn = orbitInterestedIn;
  if (orbitAgeRange) updates.orbitAgeRange = orbitAgeRange;
  if (orbitBio) updates.orbitBio = orbitBio;
  if (orbitPhotos) updates.orbitPhotos = orbitPhotos;

  const user = await User.findByIdAndUpdate(req.userId, updates, { new: true });
  res.json({ message: 'Orbit profile updated', orbitEnabled: user.orbitEnabled });
});

// POST /orbit/verify — submit selfie verification (stub)
router.post('/verify', authMiddleware, async (req, res) => {
  // In production: send selfieUrl to AWS Rekognition
  // For dev: auto-approve
  await User.findByIdAndUpdate(req.userId, { orbitVerified: true });
  res.json({ message: 'Verification approved', orbitVerified: true });
});

// POST /orbit/pull/:userId — send a pull (like)
router.post('/pull/:userId', authMiddleware, async (req, res) => {
  const target = await User.findById(req.params.userId);
  if (!target) return res.status(404).json({ error: 'User not found' });

  // Deduct 1 credit for pull
  const me = req.user;
  if (me.credits < 1) return res.status(402).json({ error: 'Insufficient credits' });
  await User.findByIdAndUpdate(req.userId, { $inc: { credits: -1 } });

  // In production: check mutual pull → create match
  res.json({ message: 'Pull sent', matched: false });
});

// GET /orbit/signal-questions — conversation starters
router.get('/signal-questions', authMiddleware, (req, res) => {
  res.json({
    questions: [
      { id: '1', question: 'What song describes your life right now?' },
      { id: '2', question: 'Your ideal Sunday morning?' },
      { id: '3', question: 'Tea, coffee, or neither?' },
      { id: '4', question: 'What are you currently obsessed with?' },
      { id: '5', question: 'Last thing that made you laugh out loud?' },
    ],
  });
});

module.exports = router;
