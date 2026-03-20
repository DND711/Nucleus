'use strict';

const express = require('express');
const router = express.Router();
const Post = require('../models/Post');
const User = require('../models/User');
const { authMiddleware } = require('../middleware/auth');

// POST /posts — create a post
router.post('/', authMiddleware, async (req, res) => {
  const allowed = ['type', 'text', 'audioUrl', 'audioDurationSec', 'waveformData',
    'mediaUrl', 'mediaType', 'thumbnailUrl', 'vibeTag', 'vibeColor',
    'soundTitle', 'soundArtist', 'soundPreviewUrl', 'circleId', 'isPublic'];
  const data = { author: req.userId };
  for (const key of allowed) {
    if (req.body[key] !== undefined) data[key] = req.body[key];
  }
  if (!data.type) return res.status(400).json({ error: 'Post type required' });

  const post = await Post.create(data);
  await User.findByIdAndUpdate(req.userId, { $inc: { postsCount: 1 } });
  await post.populate('author', 'displayName username avatarUrl isVerified');

  res.status(201).json(post);
});

// GET /posts/:id
router.get('/:id', authMiddleware, async (req, res) => {
  const post = await Post.findById(req.params.id)
    .populate('author', 'displayName username avatarUrl isVerified vibes');
  if (!post || post.isDeleted) return res.status(404).json({ error: 'Post not found' });
  res.json(post);
});

// DELETE /posts/:id
router.delete('/:id', authMiddleware, async (req, res) => {
  const post = await Post.findById(req.params.id);
  if (!post) return res.status(404).json({ error: 'Post not found' });
  if (post.author.toString() !== req.userId) return res.status(403).json({ error: 'Forbidden' });
  post.isDeleted = true;
  await post.save();
  await User.findByIdAndUpdate(req.userId, { $inc: { postsCount: -1 } });
  res.json({ message: 'Post deleted' });
});

// POST /posts/:id/react — add sticker reaction
router.post('/:id/react', authMiddleware, async (req, res) => {
  const { stickerId } = req.body;
  if (!stickerId) return res.status(400).json({ error: 'stickerId required' });

  const post = await Post.findByIdAndUpdate(
    req.params.id,
    { $inc: { reactionsCount: 1, [`stickerReactions.${stickerId}`]: 1 } },
    { new: true },
  );
  if (!post) return res.status(404).json({ error: 'Post not found' });
  res.json({ reactionsCount: post.reactionsCount });
});

// GET /posts/:id/comments (stub — full comment model omitted for brevity)
router.get('/:id/comments', authMiddleware, (req, res) => {
  res.json({ comments: [], nextCursor: null });
});

module.exports = router;
