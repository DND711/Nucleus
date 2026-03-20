'use strict';

const express = require('express');
const router = express.Router();
const { authMiddleware } = require('../middleware/auth');

// POST /upload/presigned — get S3 pre-signed URL for direct upload
router.post('/presigned', authMiddleware, async (req, res) => {
  const { contentType, folder = 'media' } = req.body;
  if (!contentType) return res.status(400).json({ error: 'contentType required' });

  if (process.env.NODE_ENV !== 'production') {
    // Dev stub: return a fake URL
    const key = `${folder}/${req.userId}/${Date.now()}`;
    return res.json({
      uploadUrl: `https://nucleus-dev-bucket.s3.amazonaws.com/${key}?presigned=true`,
      publicUrl: `${process.env.AWS_CLOUDFRONT_URL || 'https://cdn.nucleus.app'}/${key}`,
    });
  }

  try {
    const AWS = require('aws-sdk');
    const s3 = new AWS.S3();
    const key = `${folder}/${req.userId}/${Date.now()}_${Math.random().toString(36).slice(2)}`;
    const uploadUrl = await s3.getSignedUrlPromise('putObject', {
      Bucket: process.env.AWS_S3_BUCKET,
      Key: key,
      ContentType: contentType,
      Expires: 300,
    });
    const publicUrl = `${process.env.AWS_CLOUDFRONT_URL}/${key}`;
    res.json({ uploadUrl, publicUrl });
  } catch (err) {
    res.status(500).json({ error: 'Failed to generate upload URL' });
  }
});

module.exports = router;
