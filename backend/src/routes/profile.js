'use strict';

const express = require('express');
const router = express.Router();
const User = require('../models/User');
const { authMiddleware } = require('../middleware/auth');

// GET /profile/me
router.get('/me', authMiddleware, (req, res) => {
  const u = req.user;
  res.json({
    id: u._id,
    phone: u.phone,
    displayName: u.displayName,
    username: u.username,
    bio: u.bio,
    avatarUrl: u.avatarUrl,
    coverUrl: u.coverUrl,
    vibes: u.vibes,
    credits: u.credits,
    isVerified: u.isVerified,
    verificationLevel: u.verificationLevel,
    onboardingComplete: u.onboardingComplete,
    vibeSetupComplete: u.vibeSetupComplete,
    followersCount: u.followersCount,
    followingCount: u.followingCount,
    postsCount: u.postsCount,
    isBackstageEnabled: u.isBackstageEnabled,
    orbitEnabled: u.orbitEnabled,
    createdAt: u.createdAt,
  });
});

// PATCH /profile/me
router.patch('/me', authMiddleware, async (req, res) => {
  const allowed = ['displayName', 'username', 'bio', 'avatarUrl', 'coverUrl'];
  const updates = {};
  for (const key of allowed) {
    if (req.body[key] !== undefined) updates[key] = req.body[key];
  }
  if (updates.displayName && !req.user.onboardingComplete) {
    updates.onboardingComplete = true;
  }
  try {
    const user = await User.findByIdAndUpdate(req.userId, updates, { new: true });
    res.json({ message: 'Profile updated', user: { id: user._id, ...updates, onboardingComplete: user.onboardingComplete } });
  } catch (err) {
    if (err.code === 11000) return res.status(409).json({ error: 'Username already taken' });
    throw err;
  }
});

// POST /profile/vibe
router.post('/vibe', authMiddleware, async (req, res) => {
  const { vibes } = req.body;
  if (!Array.isArray(vibes) || vibes.length === 0) {
    return res.status(400).json({ error: 'Vibes array required' });
  }
  const user = await User.findByIdAndUpdate(
    req.userId,
    { vibes: vibes.slice(0, 3), vibeSetupComplete: true },
    { new: true },
  );
  res.json({ message: 'Vibe saved', vibes: user.vibes });
});

// GET /profile/:username
router.get('/:username', authMiddleware, async (req, res) => {
  const user = await User.findOne({ username: req.params.username })
    .select('displayName username bio avatarUrl coverUrl vibes isVerified followersCount followingCount postsCount createdAt');
  if (!user) return res.status(404).json({ error: 'User not found' });
  res.json(user);
});

module.exports = router;
