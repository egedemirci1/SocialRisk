import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/premium_purchase_service.dart';

final premiumPurchaseServiceProvider = Provider<PremiumPurchaseService>((ref) {
  final service = PremiumPurchaseService();
  unawaited(service.init());
  ref.onDispose(() {
    unawaited(service.dispose());
  });
  return service;
});
