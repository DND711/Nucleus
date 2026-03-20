'use strict';

const express = require('express');
const router = express.Router();
const Post = require('../models/Post');
const { authMiddleware } = require('../middleware/auth');

// GET /feed — cursor-based paginated home feed
router.get('/', authMiddleware, async (req, res) => {
  const limit = Math.min(parseInt(req.query.limit) || 20, 50);
  const cursor = req.query.cursor; // ISO date string of last post's createdAt

  const query = { isDeleted: false, isHidden: false, isPublic: true };
  if (cursor) query.createdAt = { $lt: new Date(cursor) };

  const posts = await Post.find(query)
    .sort({ createdAt: -1 })
    .limit(limit + 1)
    .populate('author', 'displayName username avatarUrl isVerified vibes')
    .lean();

  const hasMore = posts.length > limit;
  if (hasMore) posts.pop();

  const nextCursor = hasMore && posts.length > 0
    ? posts[posts.length - 1].createdAt.toISOString()
    : null;

  res.json({ posts, nextCursor, hasMore });
});

module.exports = router;
