import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../core/constants/asset_paths.dart';

/// Displays a Lottie burst animation when a sticker is tapped.
/// Wrap around any widget that should trigger the animation.
class StickerBurst extends StatefulWidget {
  const StickerBurst({
    super.key,
    required this.child,
    this.onBurst,
    this.burstSize = 80.0,
  });

  final Widget child;
  final VoidCallback? onBurst;
  final double burstSize;

  @override
  State<StickerBurst> createState() => _StickerBurstState();
}

class _StickerBurstState extends State<StickerBurst>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _show = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() => _show = false);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void trigger() {
    widget.onBurst?.call();
    if (!_show) {
      setState(() => _show = true);
      _controller.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: trigger,
      child: Stack(
        alignment: Alignment.center,
        children: [
          widget.child,
          if (_show)
            IgnorePointer(
              child: SizedBox(
                width: widget.burstSize,
                height: widget.burstSize,
                child: Lottie.asset(
                  AssetPaths.stickerBurst,
                  controller: _controller,
                  onLoaded: (composition) {
                    _controller.duration = composition.duration;
                  },
                  repeat: false,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
