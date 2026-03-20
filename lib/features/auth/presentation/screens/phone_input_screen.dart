import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/nucleus_button.dart';
import '../../providers/auth_provider.dart';

class PhoneInputScreen extends ConsumerStatefulWidget {
  const PhoneInputScreen({super.key});

  @override
  ConsumerState<PhoneInputScreen> createState() => _PhoneInputScreenState();
}

class _PhoneInputScreenState extends ConsumerState<PhoneInputScreen> {
  final _phoneController = TextEditingController();
  String _countryCode = '+91';
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String get _fullPhone => '$_countryCode${_phoneController.text.trim()}';

  bool get _isValid => _phoneController.text.trim().length >= 10;

  Future<void> _sendOtp() async {
    if (!_isValid || _isLoading) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await ref.read(authStateProvider.notifier).sendOtp(_fullPhone);
      if (mounted) {
        context.push('/auth/phone/otp', extra: _fullPhone);
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.massive),
              Text(
                'Nucleus',
                style: AppTextStyles.displayMedium.copyWith(
                  color: AppColors.primaryLight,
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2),
              AppSpacing.vGapSm,
              Text(
                AppStrings.tagline,
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
              ).animate(delay: 100.ms).fadeIn(duration: 400.ms),
              const Spacer(),
              Text(
                AppStrings.enterPhone,
                style: AppTextStyles.headlineMedium,
              ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
              AppSpacing.vGapLg,
              _PhoneField(
                countryCode: _countryCode,
                controller: _phoneController,
                onCountryChanged: (code) => setState(() => _countryCode = code),
                onSubmitted: (_) => _sendOtp(),
              ).animate(delay: 300.ms).fadeIn(duration: 400.ms),
              if (_error != null) ...[
                AppSpacing.vGapSm,
                Text(
                  _error!,
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
                ),
              ],
              AppSpacing.vGapXl,
              ListenableBuilder(
                listenable: _phoneController,
                builder: (context, _) {
                  return NucleusButton(
                    label: AppStrings.sendOtp,
                    onPressed: _isValid ? _sendOtp : null,
                    isLoading: _isLoading,
                  );
                },
              ).animate(delay: 400.ms).fadeIn(duration: 400.ms),
              const Spacer(flex: 2),
              Center(
                child: Text(
                  'By continuing you agree to our Terms & Privacy Policy.',
                  style: AppTextStyles.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ),
              AppSpacing.vGapLg,
            ],
          ),
        ),
      ),
    );
  }
}

class _PhoneField extends StatelessWidget {
  const _PhoneField({
    required this.countryCode,
    required this.controller,
    required this.onCountryChanged,
    required this.onSubmitted,
  });

  final String countryCode;
  final TextEditingController controller;
  final ValueChanged<String> onCountryChanged;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            // TODO: Show country picker
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            child: Row(
              children: [
                Text(countryCode, style: AppTextStyles.bodyLarge),
                AppSpacing.hGapXs,
                const Icon(Icons.arrow_drop_down_rounded, color: AppColors.textSecondary, size: 20),
              ],
            ),
          ),
        ),
        AppSpacing.hGapSm,
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: AppTextStyles.bodyLarge,
            decoration: const InputDecoration(
              hintText: '98765 43210',
            ),
            onSubmitted: onSubmitted,
            autofocus: true,
          ),
        ),
      ],
    );
  }
}
