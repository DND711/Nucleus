import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/nucleus_button.dart';

class SignalQuestionsScreen extends ConsumerStatefulWidget {
  const SignalQuestionsScreen({super.key});

  @override
  ConsumerState<SignalQuestionsScreen> createState() => _SignalQuestionsScreenState();
}

class _SignalQuestionsScreenState extends ConsumerState<SignalQuestionsScreen> {
  final List<_QAPair> _answers = [
    _QAPair('One place you want to visit before you die?', ''),
    _QAPair('What are you building right now?', ''),
  ];

  bool get _canContinue => _answers.where((a) => a.answer.trim().isNotEmpty).length >= 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Signal Questions'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your answers', style: AppTextStyles.headlineLarge),
            AppSpacing.vGapSm,
            Text(
              'Answer honestly. These are the signals that connect you to your gravitational pull.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
            AppSpacing.vGapXxl,
            ..._answers.indexed.map((e) {
              final i = e.$1;
              final qa = e.$2;
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                child: _QuestionCard(
                  question: qa.question,
                  answer: qa.answer,
                  onChanged: (v) => setState(() => _answers[i] = _QAPair(qa.question, v)),
                ),
              );
            }),
            NucleusButton(
              label: 'Complete Setup',
              onPressed: _canContinue ? () => context.go(AppRoutes.orbit) : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({required this.question, required this.answer, required this.onChanged});
  final String question;
  final String answer;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(question, style: AppTextStyles.bodyMedium),
        AppSpacing.vGapSm,
        TextField(
          onChanged: onChanged,
          style: AppTextStyles.bodyLarge,
          maxLines: 3,
          maxLength: 200,
          decoration: const InputDecoration(hintText: 'Your honest answer...'),
        ),
      ],
    );
  }
}

class _QAPair {
  const _QAPair(this.question, this.answer);
  final String question;
  final String answer;
}
