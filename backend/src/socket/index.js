'use strict';

const jwt = require('jsonwebtoken');

const connectedUsers = new Map(); // userId -> socketId

function initSocket(io) {
  // Auth middleware for Socket.io
  io.use((socket, next) => {
    const token = socket.handshake.auth?.token;
    if (!token) return next(new Error('No token'));
    try {
      const payload = jwt.verify(token, process.env.JWT_ACCESS_SECRET || 'dev_access_secret');
      socket.userId = payload.sub;
      next();
    } catch {
      next(new Error('Invalid token'));
    }
  });

  io.on('connection', (socket) => {
    const { userId } = socket;
    connectedUsers.set(userId, socket.id);
    console.log(`🔌 Socket connected: ${userId}`);

    socket.join(`user:${userId}`);

    // WebRTC signalling
    socket.on('call:offer', ({ targetUserId, offer, callType }) => {
      io.to(`user:${targetUserId}`).emit('call:incoming', {
        callerId: userId,
        offer,
        callType,
      });
    });

    socket.on('call:answer', ({ targetUserId, answer }) => {
      io.to(`user:${targetUserId}`).emit('call:answer', { answer });
    });

    socket.on('call:ice-candidate', ({ targetUserId, candidate }) => {
      io.to(`user:${targetUserId}`).emit('call:ice-candidate', { candidate });
    });

    socket.on('call:end', ({ targetUserId }) => {
      io.to(`user:${targetUserId}`).emit('call:ended', { by: userId });
    });

    socket.on('call:reject', ({ targetUserId }) => {
      io.to(`user:${targetUserId}`).emit('call:rejected', { by: userId });
    });

    // Typing indicators
    socket.on('message:typing', ({ targetUserId }) => {
      io.to(`user:${targetUserId}`).emit('message:typing', { from: userId });
    });

    // Online status
    socket.on('disconnect', () => {
      connectedUsers.delete(userId);
      console.log(`🔌 Socket disconnected: ${userId}`);
    });
  });
}

function isOnline(userId) {
  return connectedUsers.has(userId);
}

function emitToUser(io, userId, event, data) {
  io.to(`user:${userId}`).emit(event, data);
}

module.exports = { initSocket, isOnline, emitToUser };
