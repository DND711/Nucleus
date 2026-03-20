import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class LiveSelfieScreen extends ConsumerStatefulWidget {
  const LiveSelfieScreen({super.key});

  @override
  ConsumerState<LiveSelfieScreen> createState() => _LiveSelfieScreenState();
}

class _LiveSelfieScreenState extends ConsumerState<LiveSelfieScreen> {
  CameraController? _controller;
  bool _isInitialized = false;
  _Challenge _currentChallenge = _Challenge.lookLeft;
  int _countdown = 3;
  Timer? _countdownTimer;
  bool _isCapturing = false;
  bool _isComplete = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final front = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );
    _controller = CameraController(front, ResolutionPreset.medium);
    await _controller!.initialize();
    if (mounted) {
      setState(() => _isInitialized = true);
      _startChallenge();
    }
  }

  void _startChallenge() {
    _countdown = 3;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown <= 0) {
        timer.cancel();
        _captureAndVerify();
      } else {
        setState(() => _countdown--);
      }
    });
  }

  Future<void> _captureAndVerify() async {
    if (_isCapturing || _controller == null) return;
    setState(() => _isCapturing = true);

    try {
      final image = await _controller!.takePicture();
      // TODO: Send to AWS Rekognition via backend
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call

      if (mounted) {
        if (_currentChallenge == _Challenge.lookLeft) {
          setState(() {
            _currentChallenge = _Challenge.lookRight;
            _isCapturing = false;
          });
          _startChallenge();
        } else {
          setState(() {
            _isComplete = true;
            _isCapturing = false;
          });
          await Future.delayed(const Duration(seconds: 1));
          if (mounted) context.push(AppRoutes.signalQuestions);
        }
      }
    } catch (e) {
      setState(() => _isCapturing = false);
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    onPressed: () => context.pop(),
                  ),
                  const Spacer(),
                  Text('Live Verification', style: AppTextStyles.headlineSmall.copyWith(color: Colors.white)),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            // Camera
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                  child: _isInitialized
                      ? CameraPreview(_controller!)
                      : const Center(child: CircularProgressIndicator(color: Colors.white)),
                ),
              ),
            ),
            // Challenge instruction
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                children: [
                  if (_isComplete)
                    Column(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: AppColors.verifiedGreen, size: 56),
                        AppSpacing.vGapMd,
                        Text('Verified!', style: AppTextStyles.headlineLarge.copyWith(color: Colors.white)),
                      ],
                    ).animate().scale(duration: 400.ms, curve: Curves.elasticOut)
                  else ...[
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        _currentChallenge == _Challenge.lookLeft
                            ? 'Look to your LEFT'
                            : 'Look to your RIGHT',
                        key: ValueKey(_currentChallenge),
                        style: AppTextStyles.headlineMedium.copyWith(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    AppSpacing.vGapMd,
                    Text(
                      _isCapturing ? 'Verifying...' : 'Capturing in $_countdown',
                      style: AppTextStyles.bodyLarge.copyWith(color: Colors.white70),
                    ),
                    AppSpacing.vGapMd,
                    LinearProgressIndicator(
                      value: _isCapturing ? null : (3 - _countdown) / 3,
                      backgroundColor: Colors.white24,
                      color: AppColors.orbitGlow,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _Challenge { lookLeft, lookRight }
