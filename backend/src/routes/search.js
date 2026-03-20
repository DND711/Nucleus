'use strict';

const express = require('express');
const router = express.Router();
const User = require('../models/User');
const Post = require('../models/Post');
const Circle = require('../models/Circle');
const { authMiddleware } = require('../middleware/auth');

// GET /search?q=&type=all|users|posts|circles
router.get('/', authMiddleware, async (req, res) => {
  const { q, type = 'all' } = req.query;
  if (!q || q.trim().length < 2) return res.status(400).json({ error: 'Query too short' });

  const regex = new RegExp(q.trim(), 'i');
  const results = {};

  if (type === 'all' || type === 'users') {
    results.users = await User.find({
      $or: [{ displayName: regex }, { username: regex }],
      isActive: true,
    }).select('displayName username avatarUrl isVerified vibes').limit(10).lean();
  }

  if (type === 'all' || type === 'posts') {
    results.posts = await Post.find({ text: regex, isDeleted: false, isPublic: true })
      .select('text type author createdAt reactionsCount')
      .populate('author', 'displayName username avatarUrl')
      .limit(10).lean();
  }

  if (type === 'all' || type === 'circles') {
    results.circles = await Circle.find({ name: regex, isActive: true })
      .select('name slug description coverUrl membersCount').limit(10).lean();
  }

  res.json(results);
});

module.exports = router;
