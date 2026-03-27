import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../domain/premium_constants.dart';

class PremiumPurchaseService {
  PremiumPurchaseService({
    InAppPurchase? iap,
    FirebaseFunctions? functions,
  })  : _iap = iap ?? InAppPurchase.instance,
        _functions = functions ?? FirebaseFunctions.instance;

  final InAppPurchase _iap;
  final FirebaseFunctions _functions;

  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;
  final _availableProductsController =
      StreamController<List<ProductDetails>>.broadcast();

  Stream<List<ProductDetails>> get availableProductsStream =>
      _availableProductsController.stream;

  Future<void> init() async {
    final available = await _iap.isAvailable();
    if (!available) {
      _availableProductsController.add(const []);
      return;
    }
    await _loadProducts();
    _purchaseSub ??= _iap.purchaseStream.listen(
      _handlePurchases,
      onError: (Object error, StackTrace stackTrace) {
        debugPrint('PremiumPurchaseService.purchaseStream error: $error');
      },
    );
  }

  Future<void> _loadProducts() async {
    final response = await _iap.queryProductDetails(
      PremiumConstants.productIds,
    );
    _availableProductsController.add(response.productDetails);
  }

  Future<void> buyLifetimePremium() async {
    final response = await _iap.queryProductDetails(
      PremiumConstants.productIds,
    );
    ProductDetails? product;
    for (final item in response.productDetails) {
      if (item.id == PremiumConstants.premiumLifetimeProductId) {
        product = item;
        break;
      }
    }

    if (product == null) {
      throw Exception('Premium ürünü mağazada bulunamadı.');
    }

    final param = PurchaseParam(productDetails: product);
    final launched = await _iap.buyNonConsumable(purchaseParam: param);
    if (!launched) {
      throw Exception('Satın alma akışı başlatılamadı.');
    }
  }

  Future<void> restorePurchases() => _iap.restorePurchases();

  Future<void> _handlePurchases(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      try {
        if (purchase.status == PurchaseStatus.purchased ||
            purchase.status == PurchaseStatus.restored) {
          await _activatePremiumOnBackend(purchase);
        } else if (purchase.status == PurchaseStatus.error) {
          debugPrint('Premium purchase error: ${purchase.error}');
        }
      } finally {
        if (purchase.pendingCompletePurchase) {
          await _iap.completePurchase(purchase);
        }
      }
    }
  }

  Future<void> _activatePremiumOnBackend(PurchaseDetails purchase) async {
    final callable = _functions.httpsCallable('activatePremium');
    await callable.call(<String, dynamic>{
      'productId': purchase.productID,
      'purchaseId': purchase.purchaseID,
      'verificationData': purchase.verificationData.serverVerificationData,
      'source': defaultTargetPlatform == TargetPlatform.iOS
          ? 'app_store'
          : 'play_store',
    });
  }

  Future<void> dispose() async {
    await _purchaseSub?.cancel();
    await _availableProductsController.close();
  }
}
