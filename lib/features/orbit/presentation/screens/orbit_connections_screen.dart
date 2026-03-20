import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/nucleus_avatar.dart';

class OrbitConnectionsScreen extends ConsumerWidget {
  const OrbitConnectionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
        title: const Text('Connections'),
      ),
      body: const Center(
        child: Text('No connections yet.\nPull someone into orbit!',
            style: TextStyle(color: AppColors.textTertiary), textAlign: TextAlign.center),
      ),
    );
  }
}
