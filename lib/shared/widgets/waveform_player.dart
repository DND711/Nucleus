import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

class WaveformPlayer extends StatefulWidget {
  const WaveformPlayer({
    super.key,
    required this.audioUrl,
    this.waveformData,
    this.duration,
    this.isCompact = false,
    this.accentColor = AppColors.primaryLight,
  });

  final String audioUrl;
  final List<double>? waveformData;
  final Duration? duration;
  final bool isCompact;
  final Color accentColor;

  @override
  State<WaveformPlayer> createState() => _WaveformPlayerState();
}

class _WaveformPlayerState extends State<WaveformPlayer>
    with SingleTickerProviderStateMixin {
  final _player = FlutterSoundPlayer();
  bool _isInitialized = false;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _total = Duration.zero;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _player.openPlayer();
    setState(() {
      _isInitialized = true;
      _total = widget.duration ?? Duration.zero;
    });
  }

  @override
  void dispose() {
    _player.closePlayer();
    super.dispose();
  }

  Future<void> _togglePlayback() async {
    if (!_isInitialized) return;

    if (_isPlaying) {
      await _player.pausePlayer();
      setState(() => _isPlaying = false);
    } else {
      await _player.startPlayer(
        fromURI: widget.audioUrl,
        whenFinished: () {
          if (mounted) setState(() => _isPlaying = false);
        },
      );
      _player.setSubscriptionDuration(const Duration(milliseconds: 100));
      _player.onProgress!.listen((event) {
        if (mounted) {
          setState(() {
            _position = event.position;
            _total = event.duration;
          });
        }
      });
      setState(() => _isPlaying = true);
    }
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final progress = _total.inMilliseconds > 0
        ? _position.inMilliseconds / _total.inMilliseconds
        : 0.0;

    return Row(
      children: [
        GestureDetector(
          onTap: _togglePlayback,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: widget.isCompact ? 32 : 40,
            height: widget.isCompact ? 32 : 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isPlaying ? widget.accentColor : AppColors.surfaceElevated,
              border: Border.all(
                color: _isPlaying ? widget.accentColor : AppColors.border,
                width: 0.5,
              ),
            ),
            child: Icon(
              _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              size: widget.isCompact ? 16 : 20,
              color: _isPlaying ? AppColors.textPrimary : widget.accentColor,
            ),
          ),
        ),
        AppSpacing.hGapSm,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RepaintBoundary(
                child: CustomPaint(
                  size: Size(double.infinity, widget.isCompact ? 24 : 36),
                  painter: _WaveformPainter(
                    data: widget.waveformData ?? _generateDefaultWaveform(),
                    progress: progress,
                    activeColor: widget.accentColor,
                    inactiveColor: AppColors.border,
                  ),
                ),
              ),
              if (!widget.isCompact) ...[
                AppSpacing.vGapXs,
                Text(
                  _total.inMilliseconds > 0
                      ? '${_formatDuration(_position)} / ${_formatDuration(_total)}'
                      : _formatDuration(_total),
                  style: AppTextStyles.timestamp,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  List<double> _generateDefaultWaveform() {
    final rng = math.Random(42);
    return List.generate(40, (_) => 0.2 + rng.nextDouble() * 0.8);
  }
}

class _WaveformPainter extends CustomPainter {
  const _WaveformPainter({
    required this.data,
    required this.progress,
    required this.activeColor,
    required this.inactiveColor,
  });

  final List<double> data;
  final double progress;
  final Color activeColor;
  final Color inactiveColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final barWidth = (size.width / data.length) * 0.6;
    final gap = (size.width / data.length) * 0.4;
    final midY = size.height / 2;
    final activePaint = Paint()
      ..color = activeColor
      ..strokeCap = StrokeCap.round;
    final inactivePaint = Paint()
      ..color = inactiveColor
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < data.length; i++) {
      final x = i * (barWidth + gap) + barWidth / 2;
      final barHeight = data[i].clamp(0.1, 1.0) * midY;
      final isActive = i / data.length <= progress;

      final paint = isActive ? activePaint : inactivePaint;
      paint.strokeWidth = barWidth;
      canvas.drawLine(
        Offset(x, midY - barHeight),
        Offset(x, midY + barHeight),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.data != data;
  }
}
