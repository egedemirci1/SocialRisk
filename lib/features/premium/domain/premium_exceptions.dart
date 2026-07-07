/// In-app purchase bu platformda desteklenmiyor (ör. web).
class PremiumPurchaseUnavailableException implements Exception {
  const PremiumPurchaseUnavailableException();

  @override
  String toString() => 'PremiumPurchaseUnavailableException';
}
