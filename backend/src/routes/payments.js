'use strict';

const express = require('express');
const router = express.Router();
const User = require('../models/User');
const { authMiddleware } = require('../middleware/auth');

// POST /payments/order — create Razorpay order
router.post('/order', authMiddleware, async (req, res) => {
  const { packageId } = req.body;
  const packages = {
    credits_100: { credits: 100, amountPaise: 4900 },
    credits_500: { credits: 500, amountPaise: 19900 },
    credits_1200: { credits: 1200, amountPaise: 39900 },
    credits_3000: { credits: 3000, amountPaise: 89900 },
  };

  const pkg = packages[packageId];
  if (!pkg) return res.status(400).json({ error: 'Invalid package' });

  if (process.env.NODE_ENV !== 'production') {
    // Dev stub: return a mock order
    return res.json({
      orderId: `order_dev_${Date.now()}`,
      amount: pkg.amountPaise,
      currency: 'INR',
      credits: pkg.credits,
    });
  }

  try {
    const Razorpay = require('razorpay');
    const instance = new Razorpay({
      key_id: process.env.RAZORPAY_KEY_ID,
      key_secret: process.env.RAZORPAY_KEY_SECRET,
    });
    const order = await instance.orders.create({
      amount: pkg.amountPaise,
      currency: 'INR',
      receipt: `nucleus_${req.userId}_${Date.now()}`,
    });
    res.json({ orderId: order.id, amount: order.amount, currency: order.currency, credits: pkg.credits });
  } catch (err) {
    res.status(500).json({ error: 'Payment gateway error' });
  }
});

// POST /payments/verify — verify and credit after successful payment
router.post('/verify', authMiddleware, async (req, res) => {
  const { orderId, paymentId, signature, credits } = req.body;

  if (process.env.NODE_ENV !== 'production') {
    // Dev: just award credits
    const user = await User.findByIdAndUpdate(
      req.userId,
      { $inc: { credits } },
      { new: true },
    );
    return res.json({ success: true, credits: user.credits });
  }

  try {
    const crypto = require('crypto');
    const expectedSig = crypto
      .createHmac('sha256', process.env.RAZORPAY_KEY_SECRET)
      .update(`${orderId}|${paymentId}`)
      .digest('hex');

    if (expectedSig !== signature) return res.status(400).json({ error: 'Invalid signature' });

    const user = await User.findByIdAndUpdate(
      req.userId,
      { $inc: { credits } },
      { new: true },
    );
    res.json({ success: true, credits: user.credits });
  } catch {
    res.status(500).json({ error: 'Verification failed' });
  }
});

module.exports = router;
