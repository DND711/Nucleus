'use strict';

const mongoose = require('mongoose');

const notificationSchema = new mongoose.Schema({
  recipient: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true, index: true },
  actor: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  type: {
    type: String,
    enum: ['follow', 'like', 'comment', 'repost', 'tip', 'mention', 'call', 'orbit_pull', 'orbit_match', 'circle_invite', 'daily_credits'],
    required: true,
  },
  entityType: String, // 'post', 'circle', 'call'
  entityId: mongoose.Schema.Types.ObjectId,
  body: String,
  isRead: { type: Boolean, default: false },
}, {
  timestamps: true,
});

notificationSchema.index({ recipient: 1, createdAt: -1 });

module.exports = mongoose.model('Notification', notificationSchema);
