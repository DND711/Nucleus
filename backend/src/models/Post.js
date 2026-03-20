'use strict';

const mongoose = require('mongoose');

const postSchema = new mongoose.Schema({
  author: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true, index: true },
  type: {
    type: String,
    enum: ['spark', 'voice', 'moment', 'vibe', 'soundDrop', 'moodBoard'],
    required: true,
  },

  // Spark (text)
  text: { type: String, maxlength: 500 },

  // Voice
  audioUrl: String,
  audioDurationSec: Number,
  waveformData: [Number],

  // Moment (image/video)
  mediaUrl: String,
  mediaType: { type: String, enum: ['image', 'video'] },
  thumbnailUrl: String,

  // Vibe check
  vibeTag: String,
  vibeColor: String,

  // Sound Drop
  soundTitle: String,
  soundArtist: String,
  soundPreviewUrl: String,

  // Circles
  circleId: { type: mongoose.Schema.Types.ObjectId, ref: 'Circle', index: true },
  isPublic: { type: Boolean, default: true },

  // Engagement
  reactionsCount: { type: Number, default: 0 },
  commentsCount: { type: Number, default: 0 },
  repostsCount: { type: Number, default: 0 },
  tipsTotal: { type: Number, default: 0 },

  // Sticker reactions map: { stickerId -> count }
  stickerReactions: { type: Map, of: Number, default: {} },

  // Moderation
  isDeleted: { type: Boolean, default: false },
  isHidden: { type: Boolean, default: false },
}, {
  timestamps: true,
});

postSchema.index({ createdAt: -1 });
postSchema.index({ author: 1, createdAt: -1 });
postSchema.index({ circleId: 1, createdAt: -1 });

module.exports = mongoose.model('Post', postSchema);
