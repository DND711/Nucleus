'use strict';

const express = require('express');
const router = express.Router();
const mongoose = require('mongoose');
const { generateOtp, storeOtp, verifyOtp, sendOtpSms } = require('../utils/otp');
const { generateAccessToken, generateRefreshToken, verifyRefreshToken } = require('../utils/tokens');
const { authMiddleware } = require('../middleware/auth');
const devStore = require('../utils/devStore');

function isMongoLive() {
  return mongoose.connection.readyState === 1;
}

async function findOrCreateUser(phone, countryCode) {
  if (isMongoLive()) {
    const User = require('../models/User');
    let user = await User.findOne({ phone });
    const isNew = !user;
    if (!user) user = await User.create({ phone, countryCode });
    return { user, isNew };
  }
  let user = devStore.findUserByPhone(phone);
  const isNew = !user;
  if (!user) user = devStore.createUser({ phone, countryCode });
  return { user, isNew };
}

async function saveRefreshToken(userId, token) {
  if (isMongoLive()) {
    const User = require('../models/User');
    await User.findByIdAndUpdate(userId, { refreshToken: token, lastSeenAt: new Date() });
  } else {
    devStore.updateUser(userId, { refreshToken: token, lastSeenAt: new Date() });
  }
}

// POST /auth/otp/send
router.post('/otp/send', async (req, res) => {
  const { phone, countryCode = '+91' } = req.body;
  if (!phone) return res.status(400).json({ error: 'Phone required' });

  const otp = generateOtp();
  const fullPhone = `${countryCode}${phone}`;
  await storeOtp(fullPhone, otp);
  await sendOtpSms(fullPhone, otp);

  res.json({ message: 'OTP sent', ...(process.env.NODE_ENV !== 'production' && { otp }) });
});

// POST /auth/otp/verify
router.post('/otp/verify', async (req, res) => {
  const { phone, countryCode = '+91', otp } = req.body;
  if (!phone || !otp) return res.status(400).json({ error: 'Phone and OTP required' });

  const fullPhone = `${countryCode}${phone}`;
  const valid = await verifyOtp(fullPhone, otp);
  if (!valid) return res.status(401).json({ error: 'Invalid or expired OTP' });

  const { user, isNew } = await findOrCreateUser(fullPhone, countryCode);

  const accessToken = generateAccessToken(user._id.toString());
  const refreshToken = generateRefreshToken(user._id.toString());
  await saveRefreshToken(user._id.toString(), refreshToken);

  res.json({
    accessToken,
    refreshToken,
    isNewUser: isNew,
    user: {
      id: user._id,
      phone: user.phone,
      displayName: user.displayName,
      username: user.username,
      avatarUrl: user.avatarUrl,
      onboardingComplete: user.onboardingComplete,
      vibeSetupComplete: user.vibeSetupComplete,
      credits: user.credits,
    },
  });
});

// POST /auth/token/refresh
router.post('/token/refresh', async (req, res) => {
  const { refreshToken } = req.body;
  if (!refreshToken) return res.status(400).json({ error: 'Refresh token required' });

  try {
    const payload = verifyRefreshToken(refreshToken);
    let user;
    if (isMongoLive()) {
      const User = require('../models/User');
      user = await User.findById(payload.sub);
    } else {
      user = devStore.findUserById(payload.sub);
    }
    if (!user || user.refreshToken !== refreshToken) {
      return res.status(401).json({ error: 'Invalid refresh token' });
    }
    const newAccessToken = generateAccessToken(user._id.toString());
    res.json({ accessToken: newAccessToken });
  } catch {
    res.status(401).json({ error: 'Invalid or expired refresh token' });
  }
});

// POST /auth/logout
router.post('/logout', authMiddleware, async (req, res) => {
  if (isMongoLive()) {
    const User = require('../models/User');
    await User.findByIdAndUpdate(req.userId, { $unset: { refreshToken: 1 } });
  } else {
    devStore.updateUser(req.userId, { refreshToken: null });
  }
  res.json({ message: 'Logged out' });
});

module.exports = router;
