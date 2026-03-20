'use strict';

const { getRedis } = require('../config/database');

// In-memory fallback when Redis is unavailable
const otpStore = new Map();

const OTP_TTL = 300; // 5 minutes

function generateOtp() {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

async function storeOtp(phone, otp) {
  const redis = getRedis();
  const key = `otp:${phone}`;
  if (redis) {
    await redis.setEx(key, OTP_TTL, otp);
  } else {
    otpStore.set(key, { otp, expiresAt: Date.now() + OTP_TTL * 1000 });
  }
}

async function verifyOtp(phone, otp) {
  const redis = getRedis();
  const key = `otp:${phone}`;
  let stored;
  if (redis) {
    stored = await redis.get(key);
    if (stored === otp) {
      await redis.del(key);
      return true;
    }
  } else {
    const entry = otpStore.get(key);
    if (entry && entry.otp === otp && Date.now() < entry.expiresAt) {
      otpStore.delete(key);
      return true;
    }
    // DEV: accept '123456' for any phone in dev mode
    if (process.env.NODE_ENV !== 'production' && otp === '123456') return true;
  }
  // DEV convenience: accept '123456' always in non-production
  if (process.env.NODE_ENV !== 'production' && otp === '123456') return true;
  return false;
}

async function sendOtpSms(phone, otp) {
  if (process.env.NODE_ENV !== 'production') {
    console.log(`[DEV] OTP for ${phone}: ${otp}`);
    return;
  }
  // Production: send via Twilio
  try {
    const twilio = require('twilio')(process.env.TWILIO_ACCOUNT_SID, process.env.TWILIO_AUTH_TOKEN);
    await twilio.messages.create({
      body: `Your Nucleus OTP is ${otp}. Valid for 5 minutes.`,
      from: process.env.TWILIO_FROM_NUMBER,
      to: phone,
    });
  } catch (err) {
    console.error('Failed to send OTP SMS:', err.message);
    throw err;
  }
}

module.exports = { generateOtp, storeOtp, verifyOtp, sendOtpSms };
