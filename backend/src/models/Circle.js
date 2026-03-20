'use strict';

const mongoose = require('mongoose');

const circleSchema = new mongoose.Schema({
  name: { type: String, required: true, trim: true },
  slug: { type: String, unique: true, lowercase: true },
  description: { type: String, maxlength: 500 },
  coverUrl: String,
  iconUrl: String,

  owner: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  moderators: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
  members: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
  membersCount: { type: Number, default: 0 },

  type: { type: String, enum: ['public', 'private', 'invite_only'], default: 'public' },
  vibeTag: String,

  postsCount: { type: Number, default: 0 },
  isActive: { type: Boolean, default: true },
}, {
  timestamps: true,
});

module.exports = mongoose.model('Circle', circleSchema);
