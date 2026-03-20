import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/nucleus_button.dart';

class OrbitOnboardingScreen extends ConsumerStatefulWidget {
  const OrbitOnboardingScreen({super.key});

  @override
  ConsumerState<OrbitOnboardingScreen> createState() => _OrbitOnboardingScreenState();
}

class _OrbitOnboardingScreenState extends ConsumerState<OrbitOnboardingScreen> {
  final List<File> _photos = [];
  int _step = 0;
  bool _isLoading = false;

  static const _maxPhotos = 9;
  static const _minPhotos = 3;

  Future<void> _pickPhoto() async {
    if (_photos.length >= _maxPhotos) return;
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage(imageQuality: 85);
    if (picked.isEmpty) return;
    setState(() {
      for (final p in picked) {
        if (_photos.length < _maxPhotos) _photos.add(File(p.path));
      }
    });
  }

  void _removePhoto(int index) {
    setState(() => _photos.removeAt(index));
  }

  Future<void> _next() async {
    if (_step == 0) {
      if (_photos.length < _minPhotos) return;
      setState(() => _step = 1);
    } else if (_step == 1) {
      context.push(AppRoutes.liveSelfie);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text('Step ${_step + 1} of 3'),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _step == 0 ? _PhotoUploadStep(
          photos: _photos,
          onPickPhoto: _pickPhoto,
          onRemove: _removePhoto,
        ) : _SelfieIntroStep(),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: NucleusButton(
            label: _step == 0 ? 'Continue' : 'Take Live Selfie',
            onPressed: _step == 0 && _photos.length < _minPhotos ? null : _next,
            isLoading: _isLoading,
          ),
        ),
      ),
    );
  }
}

class _PhotoUploadStep extends StatelessWidget {
  const _PhotoUploadStep({
    required this.photos,
    required this.onPickPhoto,
    required this.onRemove,
  });

  final List<File> photos;
  final VoidCallback onPickPhoto;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.uploadPhotos, style: AppTextStyles.headlineLarge)
              .animate().fadeIn(duration: 300.ms),
          AppSpacing.vGapSm,
          Text(
            AppStrings.photoRequirement,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ).animate(delay: 100.ms).fadeIn(duration: 300.ms),
          AppSpacing.vGapMd,
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.orbitGlow.withOpacity(0.08),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.orbitGlow.withOpacity(0.3), width: 0.5),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_rounded, color: AppColors.orbitGlow, size: 16),
                AppSpacing.hGapSm,
                Expanded(
                  child: Text(
                    'All photos will be verified by live selfie check.',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.orbitGlow),
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.vGapXl,
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: AppSpacing.sm,
              crossAxisSpacing: AppSpacing.sm,
            ),
            itemCount: photos.length + (photos.length < 9 ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == photos.length) {
                return GestureDetector(
                  onTap: onPickPhoto,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(color: AppColors.border, width: 0.5),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_photo_alternate_outlined, color: AppColors.textTertiary, size: 28),
                        AppSpacing.vGapXs,
                        Text('Add', style: AppTextStyles.labelSmall),
                      ],
                    ),
                  ),
                );
              }
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    child: Image.file(photos[index], fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => onRemove(index),
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black54),
                        child: const Icon(Icons.close_rounded, size: 14, color: Colors.white),
                      ),
                    ),
                  ),
                  if (index == 0)
                    Positioned(
                      bottom: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                        ),
                        child: Text('Main', style: AppTextStyles.labelSmall.copyWith(color: Colors.white)),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SelfieIntroStep extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        children: [
          AppSpacing.vGapXxxl,
          const Icon(Icons.face_rounded, size: 80, color: AppColors.orbitGlow),
          AppSpacing.vGapXxl,
          Text(AppStrings.liveVerification, style: AppTextStyles.displaySmall, textAlign: TextAlign.center),
          AppSpacing.vGapMd,
          Text(
            'We will ask you to perform a pose challenge so our AI can verify you\'re a real person. Takes about 10 seconds.',
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          AppSpacing.vGapXxl,
          _VerificationStep(number: '1', text: 'Open your camera'),
          _VerificationStep(number: '2', text: 'Follow the pose challenge'),
          _VerificationStep(number: '3', text: 'Get your blue tick instantly'),
        ],
      ),
    );
  }
}

class _VerificationStep extends StatelessWidget {
  const _VerificationStep({required this.number, required this.text});
  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.orbitGlow.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.orbitGlow, width: 0.5),
            ),
            alignment: Alignment.center,
            child: Text(number, style: AppTextStyles.labelLarge.copyWith(color: AppColors.orbitGlow)),
          ),
          AppSpacing.hGapMd,
          Text(text, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}
