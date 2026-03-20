import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:go_router/go_router.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/credit_counter.dart';
import '../../providers/call_provider.dart';
import '../../providers/credits_provider_ref.dart';

class VideoCallScreen extends ConsumerStatefulWidget {
  const VideoCallScreen({super.key, required this.callId});
  final String callId;

  @override
  ConsumerState<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends ConsumerState<VideoCallScreen> {
  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();
  bool _isMuted = false;
  bool _isFrontCamera = true;
  bool _isVideoOff = false;
  Duration _elapsed = Duration.zero;
  Timer? _elapsedTimer;
  Timer? _creditTimer;
  bool _showControls = true;

  static const _creditsPerPeriod = 1; // 1 credit per 12s = 5/min

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    _initRenderers();
    _startTimers();
  }

  Future<void> _initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
    final callManager = ref.read(callManagerProvider);
    await callManager.initVideoCall(widget.callId);
    if (callManager.localStream != null && mounted) {
      _localRenderer.srcObject = callManager.localStream;
    }
  }

  void _startTimers() {
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsed += const Duration(seconds: 1));
    });

    // 1 credit per 12 seconds = 5 credits/minute
    _creditTimer = Timer.periodic(const Duration(seconds: 12), (_) {
      ref.read(creditsNotifierProvider.notifier).deduct(_creditsPerPeriod);
    });
  }

  Future<void> _endCall() async {
    _elapsedTimer?.cancel();
    _creditTimer?.cancel();
    _localRenderer.srcObject = null;
    _remoteRenderer.srcObject = null;
    await _localRenderer.dispose();
    await _remoteRenderer.dispose();
    await WakelockPlus.disable();
    ref.read(callManagerProvider).endCall(widget.callId);
    if (mounted) context.pop();
  }

  void _toggleCamera() async {
    setState(() => _isFrontCamera = !_isFrontCamera);
    // Flip camera via WebRTC
    await Helper.switchCamera(ref.read(callManagerProvider).localStream!.getVideoTracks().first);
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    _elapsedTimer?.cancel();
    _creditTimer?.cancel();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => setState(() => _showControls = !_showControls),
        child: Stack(
          children: [
            // Remote video (full screen)
            Positioned.fill(
              child: RTCVideoView(
                _remoteRenderer,
                objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
              ),
            ),

            // Self PiP
            Positioned(
              top: 60 + MediaQuery.of(context).padding.top,
              right: 16,
              child: Container(
                width: 90,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: Colors.white24),
                ),
                clipBehavior: Clip.antiAlias,
                child: RTCVideoView(
                  _localRenderer,
                  mirror: _isFrontCamera,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                ),
              ),
            ),

            // Overlay controls
            if (_showControls) ...[
              // Top bar
              Positioned(
                top: MediaQuery.of(context).padding.top,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPadding,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.black54, Colors.transparent],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const CreditCounter(),
                      Text(_formatDuration(_elapsed),
                          style: AppTextStyles.headlineMedium.copyWith(color: Colors.white)),
                      Text('5 cr/min',
                          style: AppTextStyles.labelSmall.copyWith(color: Colors.white70)),
                    ],
                  ),
                ),
              ),

              // Bottom controls
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.only(
                    left: AppSpacing.xl,
                    right: AppSpacing.xl,
                    top: AppSpacing.xl,
                    bottom: MediaQuery.of(context).padding.bottom + AppSpacing.xl,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Colors.black54],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _VideoCallButton(
                        icon: _isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                        onTap: () {
                          setState(() => _isMuted = !_isMuted);
                          ref.read(callManagerProvider).toggleMute(_isMuted);
                        },
                        isActive: !_isMuted,
                      ),
                      _VideoCallButton(
                        icon: Icons.call_end_rounded,
                        onTap: _endCall,
                        color: AppColors.error,
                        size: 64,
                      ),
                      _VideoCallButton(
                        icon: Icons.cameraswitch_rounded,
                        onTap: _toggleCamera,
                        isActive: true,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _VideoCallButton extends StatelessWidget {
  const _VideoCallButton({
    required this.icon,
    required this.onTap,
    this.isActive = false,
    this.color,
    this.size = 52.0,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color ?? (isActive ? Colors.white24 : Colors.white12),
        ),
        child: Icon(icon, color: Colors.white, size: size * 0.45),
      ),
    );
  }
}
