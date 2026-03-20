'use strict';

/**
 * In-memory store used when MongoDB is unavailable (dev/demo mode).
 * All data is lost on restart — not for production use.
 */

const users = new Map(); // id -> user object
const byPhone = new Map(); // phone -> id
let counter = 1;

function _makeId() {
  return `dev_${counter++}`;
}

const devStore = {
  isActive() {
    const mongoose = require('mongoose');
    return mongoose.connection.readyState !== 1;
  },

  findUserByPhone(phone) {
    const id = byPhone.get(phone);
    return id ? { ...users.get(id) } : null;
  },

  findUserById(id) {
    return users.has(id) ? { ...users.get(id) } : null;
  },

  createUser({ phone, countryCode = '+91' }) {
    const id = _makeId();
    const now = new Date();
    const user = {
      _id: id,
      id,
      phone, countryCode,
      displayName: null, username: null, bio: null,
      avatarUrl: null, coverUrl: null,
      vibes: [],
      credits: 50,
      lastDailyCreditAt: null,
      isVerified: false,
      verificationLevel: 'phone',
      onboardingComplete: false,
      vibeSetupComplete: false,
      followersCount: 0, followingCount: 0, postsCount: 0,
      isBackstageEnabled: false, backstageRole: 'creator',
      orbitEnabled: false, orbitVerified: false,
      isActive: true,
      lastSeenAt: now,
      fcmTokens: [],
      refreshToken: null,
      createdAt: now, updatedAt: now,
    };
    users.set(id, user);
    byPhone.set(phone, id);
    return { ...user };
  },

  updateUser(id, updates) {
    const user = users.get(id);
    if (!user) return null;
    Object.assign(user, updates, { updatedAt: new Date() });
    if (updates.phone) byPhone.set(updates.phone, id);
    return { ...user };
  },

  incrementUser(id, increments) {
    const user = users.get(id);
    if (!user) return null;
    for (const [key, val] of Object.entries(increments)) {
      user[key] = (user[key] || 0) + val;
    }
    user.updatedAt = new Date();
    return { ...user };
  },
};

module.exports = devStore;
