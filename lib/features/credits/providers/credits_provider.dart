import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_endpoints.dart';

final creditBalanceProvider = StreamProvider<int>((ref) async* {
  // Initial load
  final balance = await _fetchBalance(ref);
  yield balance;
  // Socket.io updates would push here in production
});

Future<int> _fetchBalance(Ref ref) async {
  try {
    final dio = ref.read(dioClientProvider).dio;
    final response = await dio.get(ApiEndpoints.creditsBalance);
    return response.data['balance'] as int? ?? 0;
  } catch (_) {
    return 0;
  }
}

class CreditsNotifier extends AsyncNotifier<int> {
  @override
  Future<int> build() async => _fetchBalance(ref);

  Future<void> claimDaily() async {
    final dio = ref.read(dioClientProvider).dio;
    final response = await dio.post(ApiEndpoints.creditsClaim);
    final newBalance = response.data['balance'] as int;
    state = AsyncData(newBalance);
  }

  Future<bool> canClaimDaily() async {
    try {
      final dio = ref.read(dioClientProvider).dio;
      final response = await dio.get('/credits/claim/daily/status');
      return response.data['canClaim'] as bool;
    } catch (_) {
      return false;
    }
  }

  void deduct(int amount) {
    final current = state.valueOrNull ?? 0;
    state = AsyncData((current - amount).clamp(0, 999999));
  }

  Future<void> purchase(String packId) async {
    final dio = ref.read(dioClientProvider).dio;
    final response = await dio.post(ApiEndpoints.creditsPurchase, data: {'packId': packId});
    final newBalance = response.data['balance'] as int;
    state = AsyncData(newBalance);
  }
}

final creditsNotifierProvider = AsyncNotifierProvider<CreditsNotifier, int>(() => CreditsNotifier());
