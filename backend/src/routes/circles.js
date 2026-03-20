'use strict';

const express = require('express');
const router = express.Router();
const Circle = require('../models/Circle');
const { authMiddleware } = require('../middleware/auth');

// GET /circles — list trending circles
router.get('/', authMiddleware, async (req, res) => {
  const circles = await Circle.find({ isActive: true })
    .sort({ membersCount: -1 })
    .limit(20)
    .select('name slug description coverUrl membersCount vibeTag')
    .lean();
  res.json({ circles });
});

// POST /circles — create a circle
router.post('/', authMiddleware, async (req, res) => {
  const { name, description, type, vibeTag } = req.body;
  if (!name) return res.status(400).json({ error: 'Name required' });

  const slug = name.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/(^-|-$)/g, '');
  const circle = await Circle.create({
    name, slug, description, type, vibeTag,
    owner: req.userId,
    members: [req.userId],
    membersCount: 1,
  });
  res.status(201).json(circle);
});

// GET /circles/:id
router.get('/:id', authMiddleware, async (req, res) => {
  const circle = await Circle.findById(req.params.id)
    .populate('owner', 'displayName username avatarUrl');
  if (!circle) return res.status(404).json({ error: 'Circle not found' });
  res.json(circle);
});

// POST /circles/:id/join
router.post('/:id/join', authMiddleware, async (req, res) => {
  const circle = await Circle.findById(req.params.id);
  if (!circle) return res.status(404).json({ error: 'Circle not found' });
  if (!circle.members.includes(req.userId)) {
    circle.members.push(req.userId);
    circle.membersCount += 1;
    await circle.save();
  }
  res.json({ message: 'Joined', membersCount: circle.membersCount });
});

// DELETE /circles/:id/leave
router.delete('/:id/leave', authMiddleware, async (req, res) => {
  await Circle.findByIdAndUpdate(req.params.id, {
    $pull: { members: req.userId },
    $inc: { membersCount: -1 },
  });
  res.json({ message: 'Left circle' });
});

module.exports = router;
