import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/nucleus_button.dart';
import '../../../../shared/widgets/waveform_player.dart';

class OrbitMessageScreen extends ConsumerStatefulWidget {
  const OrbitMessageScreen({super.key, required this.connectionId});
  final String connectionId;

  @override
  ConsumerState<OrbitMessageScreen> createState() => _OrbitMessageScreenState();
}

class _OrbitMessageScreenState extends ConsumerState<OrbitMessageScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  // Demo messages
  final _messages = <_Message>[
    _Message(id: '1', isOwn: false, text: 'Hey! Saw your voice note about that design project 👀', createdAt: DateTime.now().subtract(const Duration(hours: 2))),
    _Message(id: '2', isOwn: true, text: 'Yeah! Still in early stages but so excited about it', createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 45))),
    _Message(id: '3', isOwn: false, text: 'What kind of design?', createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 40))),
  ];

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendText() {
    if (_textController.text.trim().isEmpty) return;
    setState(() {
      _messages.add(_Message(
        id: DateTime.now().toString(),
        isOwn: true,
        text: _textController.text.trim(),
        createdAt: DateTime.now(),
      ));
      _textController.clear();
    });
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
        title: const Text('Priya'),
        actions: [
          IconButton(
            icon: const Icon(Icons.call_rounded),
            onPressed: () => context.push('/calls/voice/new_call_${widget.connectionId}'),
            color: AppColors.orbitGlow,
          ),
          IconButton(
            icon: const Icon(Icons.videocam_rounded),
            onPressed: () => context.push('/calls/video/new_call_${widget.connectionId}'),
            color: AppColors.orbitGlow,
          ),
        ],
      ),
      body: Column(
        children: [
          // Free messaging label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
            color: AppColors.surfaceElevated,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_outline_rounded, size: 12, color: AppColors.textTertiary),
                AppSpacing.hGapXs,
                Text('Text messages are always free', style: AppTextStyles.labelSmall),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: _messages.length,
              itemBuilder: (context, index) => _MessageBubble(message: _messages[index]),
            ),
          ),
          _MessageInput(
            controller: _textController,
            onSend: _sendText,
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});
  final _Message message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isOwn ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
        decoration: BoxDecoration(
          color: message.isOwn ? AppColors.primary : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: message.audioUrl != null
            ? WaveformPlayer(audioUrl: message.audioUrl!, isCompact: true)
            : Text(message.text ?? '', style: AppTextStyles.bodyMedium),
      ),
    );
  }
}

class _MessageInput extends StatelessWidget {
  const _MessageInput({required this.controller, required this.onSend});
  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.sm,
        right: AppSpacing.sm,
        top: AppSpacing.sm,
        bottom: MediaQuery.of(context).padding.bottom + AppSpacing.sm,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              style: AppTextStyles.bodyMedium,
              maxLines: null,
              decoration: InputDecoration(
                hintText: 'Message...',
                contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                isDense: true,
                filled: true,
                fillColor: AppColors.surfaceElevated,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          AppSpacing.hGapXs,
          IconButton(
            icon: const Icon(Icons.send_rounded, color: AppColors.primaryLight),
            onPressed: onSend,
          ),
        ],
      ),
    );
  }
}

class _Message {
  const _Message({required this.id, required this.isOwn, this.text, this.audioUrl, required this.createdAt});
  final String id;
  final bool isOwn;
  final String? text;
  final String? audioUrl;
  final DateTime createdAt;
}

// Needed import
import 'package:flutter/scheduler.dart';
