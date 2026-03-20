import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/nucleus_button.dart';
import '../../providers/auth_provider.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  File? _avatarFile;
  bool _isLoading = false;
  bool? _usernameAvailable;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  bool get _isValid =>
      _nameController.text.trim().isNotEmpty &&
      _usernameController.text.trim().length >= 3 &&
      (_usernameAvailable ?? false);

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;

    final cropped = await ImageCropper().cropImage(
      sourcePath: picked.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(toolbarTitle: 'Crop Photo'),
        IOSUiSettings(title: 'Crop Photo'),
      ],
    );

    if (cropped != null && mounted) {
      setState(() => _avatarFile = File(cropped.path));
    }
  }

  Future<void> _checkUsername(String username) async {
    if (username.length < 3) {
      setState(() => _usernameAvailable = null);
      return;
    }
    final repo = ref.read(authRepositoryProvider);
    final available = await repo.checkUsernameAvailable(username);
    if (mounted) setState(() => _usernameAvailable = available);
  }

  Future<void> _continue() async {
    if (!_isValid || _isLoading) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      String? avatarUrl;
      // TODO: Upload avatar to S3 and get URL

      await ref.read(authStateProvider.notifier).updateProfile(
            name: _nameController.text.trim(),
            username: _usernameController.text.trim().toLowerCase(),
            bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
            avatarUrl: avatarUrl,
          );

      if (mounted) context.go(AppRoutes.vibeSelection);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.setupProfile)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSpacing.vGapXxl,
              Center(
                child: GestureDetector(
                  onTap: _pickAvatar,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: AppSpacing.avatarHero / 2,
                        backgroundColor: AppColors.surfaceElevated,
                        backgroundImage: _avatarFile != null ? FileImage(_avatarFile!) : null,
                        child: _avatarFile == null
                            ? const Icon(Icons.person_rounded, size: 48, color: AppColors.textTertiary)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.background, width: 2),
                          ),
                          child: const Icon(Icons.camera_alt_rounded, size: 16, color: AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 300.ms),
              AppSpacing.vGapXxl,
              Text(AppStrings.yourName, style: AppTextStyles.labelLarge),
              AppSpacing.vGapSm,
              TextField(
                controller: _nameController,
                style: AppTextStyles.bodyLarge,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(hintText: 'Your full name'),
                onChanged: (_) => setState(() {}),
              ),
              AppSpacing.vGapLg,
              Text(AppStrings.username, style: AppTextStyles.labelLarge),
              AppSpacing.vGapSm,
              TextField(
                controller: _usernameController,
                style: AppTextStyles.bodyLarge,
                decoration: InputDecoration(
                  hintText: '@yourname',
                  prefixText: '@',
                  suffixIcon: _usernameAvailable == null
                      ? null
                      : Icon(
                          _usernameAvailable! ? Icons.check_circle_rounded : Icons.cancel_rounded,
                          color: _usernameAvailable! ? AppColors.success : AppColors.error,
                        ),
                ),
                onChanged: _checkUsername,
              ),
              if (_usernameAvailable != null) ...[
                AppSpacing.vGapXs,
                Text(
                  _usernameAvailable! ? AppStrings.usernameAvailable : AppStrings.usernameTaken,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: _usernameAvailable! ? AppColors.success : AppColors.error,
                  ),
                ),
              ],
              AppSpacing.vGapLg,
              Text(AppStrings.bio, style: AppTextStyles.labelLarge),
              AppSpacing.vGapSm,
              TextField(
                controller: _bioController,
                style: AppTextStyles.bodyLarge,
                maxLines: 3,
                maxLength: 150,
                decoration: const InputDecoration(
                  hintText: 'Tell your world who you are...',
                  alignLabelWithHint: true,
                ),
              ),
              if (_error != null) ...[
                AppSpacing.vGapSm,
                Text(_error!, style: AppTextStyles.bodySmall.copyWith(color: AppColors.error)),
              ],
              AppSpacing.vGapXxl,
              ListenableBuilder(
                listenable: Listenable.merge([_nameController, _usernameController]),
                builder: (context, _) => NucleusButton(
                  label: AppStrings.continueText,
                  onPressed: _isValid ? _continue : null,
                  isLoading: _isLoading,
                ),
              ),
              AppSpacing.vGapXxl,
            ],
          ),
        ),
      ),
    );
  }
}
