import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/premium_purchase_service.dart';

final premiumPurchaseServiceProvider = Provider<PremiumPurchaseService>((ref) {
  final service = PremiumPurchaseService();
  ref.onDispose(() {
    service.dispose();
  });
  return service;
});
