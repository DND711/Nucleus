'use strict';

const express = require('express');
const router = express.Router();
const User = require('../models/User');
const { authMiddleware } = require('../middleware/auth');

// Follow map stored in memory for dev; production would use a Follow collection
const followMap = new Map(); // followerId -> Set<followingId>

function getFollowSet(userId) {
  if (!followMap.has(userId)) followMap.set(userId, new Set());
  return followMap.get(userId);
}

// POST /social/follow/:userId
router.post('/follow/:userId', authMiddleware, async (req, res) => {
  const { userId: targetId } = req.params;
  if (targetId === req.userId) return res.status(400).json({ error: 'Cannot follow yourself' });

  const mySet = getFollowSet(req.userId);
  if (mySet.has(targetId)) return res.status(409).json({ error: 'Already following' });

  mySet.add(targetId);
  await Promise.all([
    User.findByIdAndUpdate(req.userId, { $inc: { followingCount: 1 } }),
    User.findByIdAndUpdate(targetId, { $inc: { followersCount: 1 } }),
  ]);
  res.json({ message: 'Followed' });
});

// DELETE /social/follow/:userId
router.delete('/follow/:userId', authMiddleware, async (req, res) => {
  const { userId: targetId } = req.params;
  const mySet = getFollowSet(req.userId);
  if (!mySet.has(targetId)) return res.status(404).json({ error: 'Not following' });

  mySet.delete(targetId);
  await Promise.all([
    User.findByIdAndUpdate(req.userId, { $inc: { followingCount: -1 } }),
    User.findByIdAndUpdate(targetId, { $inc: { followersCount: -1 } }),
  ]);
  res.json({ message: 'Unfollowed' });
});

// GET /social/following/:userId
router.get('/following/:userId', authMiddleware, async (req, res) => {
  const ids = Array.from(getFollowSet(req.params.userId));
  const users = await User.find({ _id: { $in: ids } })
    .select('displayName username avatarUrl isVerified').lean();
  res.json({ users });
});

// GET /social/followers/:userId
router.get('/followers/:userId', authMiddleware, async (req, res) => {
  const result = [];
  for (const [followerId, set] of followMap.entries()) {
    if (set.has(req.params.userId)) result.push(followerId);
  }
  const users = await User.find({ _id: { $in: result } })
    .select('displayName username avatarUrl isVerified').lean();
  res.json({ users });
});

module.exports = router;
