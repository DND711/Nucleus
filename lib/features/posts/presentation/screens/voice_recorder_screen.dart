import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/nucleus_button.dart';

class VoiceRecorderScreen extends ConsumerStatefulWidget {
  const VoiceRecorderScreen({super.key});

  @override
  ConsumerState<VoiceRecorderScreen> createState() => _VoiceRecorderScreenState();
}

class _VoiceRecorderScreenState extends ConsumerState<VoiceRecorderScreen>
    with TickerProviderStateMixin {
  final _recorder = FlutterSoundRecorder();
  bool _isInitialized = false;
  bool _isRecording = false;
  bool _isPaused = false;
  bool _hasRecording = false;
  Duration _elapsed = Duration.zero;
  Timer? _timer;
  String? _recordingPath;
  final _waveformBars = <double>[];
  late AnimationController _pulseController;

  static const _maxSeconds = 60;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      if (mounted) context.pop();
      return;
    }
    await _recorder.openRecorder();
    setState(() => _isInitialized = true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _timer?.cancel();
    _recorder.closeRecorder();
    super.dispose();
  }

  Future<void> _startRecording() async {
    if (!_isInitialized) return;
    final path = '/tmp/nucleus_voice_${DateTime.now().millisecondsSinceEpoch}.aac';
    await _recorder.startRecorder(toFile: path, codec: Codec.aacADTS);
    _recorder.setSubscriptionDuration(const Duration(milliseconds: 100));
    _recorder.onProgress!.listen((e) {
      if (mounted && e.decibels != null) {
        final normalized = ((e.decibels! + 60) / 60).clamp(0.05, 1.0);
        setState(() {
          if (_waveformBars.length > 60) _waveformBars.removeAt(0);
          _waveformBars.add(normalized);
        });
      }
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsed += const Duration(seconds: 1));
      if (_elapsed.inSeconds >= _maxSeconds) _stopRecording();
    });

    setState(() {
      _isRecording = true;
      _isPaused = false;
      _recordingPath = path;
    });
  }

  Future<void> _pauseRecording() async {
    await _recorder.pauseRecorder();
    _timer?.cancel();
    setState(() => _isPaused = true);
  }

  Future<void> _resumeRecording() async {
    await _recorder.resumeRecorder();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsed += const Duration(seconds: 1));
      if (_elapsed.inSeconds >= _maxSeconds) _stopRecording();
    });
    setState(() => _isPaused = false);
  }

  Future<void> _stopRecording() async {
    await _recorder.stopRecorder();
    _timer?.cancel();
    setState(() {
      _isRecording = false;
      _isPaused = false;
      _hasRecording = true;
    });
  }

  void _discard() {
    setState(() {
      _hasRecording = false;
      _elapsed = Duration.zero;
      _waveformBars.clear();
      _recordingPath = null;
    });
  }

  Future<void> _publish() async {
    // TODO: Upload to S3 and create post
    context.pop();
  }

  String _formatElapsed() {
    final m = _elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = _elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text(AppStrings.recordVoice),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
        child: Column(
          children: [
            const Spacer(),
            // Timer
            Text(
              _formatElapsed(),
              style: AppTextStyles.displayLarge.copyWith(
                color: _isRecording ? AppColors.accent : AppColors.textTertiary,
                fontFamily: 'DMSans',
              ),
            ),
            AppSpacing.vGapLg,
            // Waveform display
            SizedBox(
              height: 80,
              child: _hasRecording || _isRecording
                  ? RepaintBoundary(
                      child: CustomPaint(
                        size: const Size(double.infinity, 80),
                        painter: _LiveWaveformPainter(
                          bars: _waveformBars,
                          color: _isRecording ? AppColors.accent : AppColors.primaryLight,
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        'Tap to start recording',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
                      ),
                    ),
            ),
            AppSpacing.vGapLg,
            // Limit indicator
            LinearProgressIndicator(
              value: _elapsed.inSeconds / _maxSeconds,
              backgroundColor: AppColors.surfaceElevated,
              color: _elapsed.inSeconds > 50 ? AppColors.warning : AppColors.primaryLight,
              minHeight: 2,
            ),
            AppSpacing.vGapXs,
            Text(
              '${_maxSeconds - _elapsed.inSeconds}s remaining',
              style: AppTextStyles.labelSmall,
            ),
            const Spacer(),
            // Controls
            if (!_hasRecording)
              _RecordControls(
                isRecording: _isRecording,
                isPaused: _isPaused,
                isInitialized: _isInitialized,
                onStart: _startRecording,
                onPause: _pauseRecording,
                onResume: _resumeRecording,
                onStop: _stopRecording,
                pulseController: _pulseController,
              )
            else
              _ReviewControls(
                onDiscard: _discard,
                onPublish: _publish,
              ),
            AppSpacing.vGapXxxl,
          ],
        ),
      ),
    );
  }
}

class _RecordControls extends StatelessWidget {
  const _RecordControls({
    required this.isRecording,
    required this.isPaused,
    required this.isInitialized,
    required this.onStart,
    required this.onPause,
    required this.onResume,
    required this.onStop,
    required this.pulseController,
  });

  final bool isRecording;
  final bool isPaused;
  final bool isInitialized;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onStop;
  final AnimationController pulseController;

  @override
  Widget build(BuildContext context) {
    if (!isRecording) {
      return Center(
        child: GestureDetector(
          onTap: onStart,
          child: AnimatedBuilder(
            animation: pulseController,
            builder: (_, __) {
              return Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accent,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withOpacity(0.3 + pulseController.value * 0.3),
                      blurRadius: 20 + pulseController.value * 20,
                      spreadRadius: 4 + pulseController.value * 4,
                    ),
                  ],
                ),
                child: const Icon(Icons.mic_rounded, color: Colors.white, size: 36),
              );
            },
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton.outlined(
          onPressed: isPaused ? onResume : onPause,
          icon: Icon(isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded),
          iconSize: 28,
        ),
        AppSpacing.hGapXl,
        GestureDetector(
          onTap: onStop,
          child: Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.error,
            ),
            child: const Icon(Icons.stop_rounded, color: Colors.white, size: 32),
          ),
        ),
      ],
    );
  }
}

class _ReviewControls extends StatelessWidget {
  const _ReviewControls({required this.onDiscard, required this.onPublish});
  final VoidCallback onDiscard;
  final VoidCallback onPublish;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onDiscard,
            child: const Text('Discard'),
          ),
        ),
        AppSpacing.hGapMd,
        Expanded(
          child: NucleusButton(
            label: 'Post Voice Note',
            onPressed: onPublish,
          ),
        ),
      ],
    );
  }
}

class _LiveWaveformPainter extends CustomPainter {
  const _LiveWaveformPainter({required this.bars, required this.color});
  final List<double> bars;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (bars.isEmpty) return;
    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round;
    final barW = (size.width / bars.length) * 0.6;
    final gapW = (size.width / bars.length) * 0.4;
    final midY = size.height / 2;
    paint.strokeWidth = barW;
    for (var i = 0; i < bars.length; i++) {
      final x = i * (barW + gapW) + barW / 2;
      final h = bars[i] * midY;
      canvas.drawLine(Offset(x, midY - h), Offset(x, midY + h), paint);
    }
  }

  @override
  bool shouldRepaint(_LiveWaveformPainter old) => old.bars != bars;
}
