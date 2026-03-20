import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/nucleus_avatar.dart';

class SearchResultsScreen extends ConsumerStatefulWidget {
  const SearchResultsScreen({super.key});

  @override
  ConsumerState<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends ConsumerState<SearchResultsScreen>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  late TabController _tabController;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: AppTextStyles.bodyLarge,
          decoration: InputDecoration(
            hintText: 'Search users, posts, circles...',
            filled: false,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: (v) => setState(() => _query = v),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Users'),
            Tab(text: 'Posts'),
            Tab(text: 'Circles'),
            Tab(text: 'Packs'),
          ],
        ),
      ),
      body: _query.isEmpty
          ? const _SearchSuggestions()
          : TabBarView(
              controller: _tabController,
              children: [
                _UsersResults(query: _query),
                _PostsResults(query: _query),
                _CirclesResults(query: _query),
                _PacksResults(query: _query),
              ],
            ),
    );
  }
}

class _SearchSuggestions extends StatelessWidget {
  const _SearchSuggestions();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_rounded, size: 48, color: AppColors.textTertiary),
          AppSpacing.vGapMd,
          Text('Search for people, posts, circles', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary)),
        ],
      ),
    );
  }
}

class _UsersResults extends StatelessWidget {
  const _UsersResults({required this.query});
  final String query;

  @override
  Widget build(BuildContext context) {
    // TODO: implement real search
    return const Center(child: CircularProgressIndicator(strokeWidth: 2));
  }
}

class _PostsResults extends StatelessWidget {
  const _PostsResults({required this.query});
  final String query;

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator(strokeWidth: 2));
  }
}

class _CirclesResults extends StatelessWidget {
  const _CirclesResults({required this.query});
  final String query;

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator(strokeWidth: 2));
  }
}

class _PacksResults extends StatelessWidget {
  const _PacksResults({required this.query});
  final String query;

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator(strokeWidth: 2));
  }
}
