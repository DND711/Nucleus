'use strict';

const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  phone: { type: String, required: true, unique: true, index: true },
  countryCode: { type: String, default: '+91' },
  displayName: { type: String, trim: true },
  username: { type: String, unique: true, sparse: true, lowercase: true, trim: true },
  bio: { type: String, maxlength: 300 },
  avatarUrl: String,
  coverUrl: String,

  // Vibe / personality
  vibes: [{ type: String }], // up to 3 vibe tags

  // Onboarding state
  onboardingComplete: { type: Boolean, default: false },
  vibeSetupComplete: { type: Boolean, default: false },

  // Credits
  credits: { type: Number, default: 50 },
  lastDailyCreditAt: Date,

  // Verification
  isVerified: { type: Boolean, default: false },
  verificationLevel: { type: String, enum: ['none', 'phone', 'selfie', 'id'], default: 'phone' },

  // Backstage (developer portal)
  isBackstageEnabled: { type: Boolean, default: false },
  backstageRole: { type: String, enum: ['creator', 'beta', 'admin'], default: 'creator' },

  // Social
  followersCount: { type: Number, default: 0 },
  followingCount: { type: Number, default: 0 },
  postsCount: { type: Number, default: 0 },

  // Orbit (dating layer)
  orbitEnabled: { type: Boolean, default: false },
  orbitVerified: { type: Boolean, default: false },
  orbitGender: String,
  orbitInterestedIn: [String],
  orbitAgeRange: { min: Number, max: Number },
  orbitBio: { type: String, maxlength: 500 },
  orbitPhotos: [String],

  // Status
  isActive: { type: Boolean, default: true },
  lastSeenAt: { type: Date, default: Date.now },

  // FCM token for push notifications
  fcmTokens: [String],

  // Auth
  refreshToken: String,
}, {
  timestamps: true,
});

module.exports = mongoose.model('User', userSchema);
