import 'package:flutter_test/flutter_test.dart';
import 'package:social_risk/shared/utils/pending_toast.dart';

void main() {
  group('PendingToast', () {
    tearDown(() {
      PendingToast.instance.consume();
    });

    test('consume returns null when nothing set', () {
      expect(PendingToast.instance.consume(), isNull);
    });

    test('setSuccess then consume returns message and true', () {
      PendingToast.instance.setSuccess('Başarılı');
      final result = PendingToast.instance.consume();
      expect(result, isNotNull);
      expect(result!.$1, 'Başarılı');
      expect(result.$2, true);
    });

    test('setError then consume returns message and false', () {
      PendingToast.instance.setError('Hata');
      final result = PendingToast.instance.consume();
      expect(result, isNotNull);
      expect(result!.$1, 'Hata');
      expect(result.$2, false);
    });

    test('after consume, next consume returns null', () {
      PendingToast.instance.setSuccess('Bir kez');
      expect(PendingToast.instance.consume(), isNotNull);
      expect(PendingToast.instance.consume(), isNull);
    });

    test('setError overwrites previous setSuccess', () {
      PendingToast.instance.setSuccess('Eski');
      PendingToast.instance.setError('Yeni');
      final result = PendingToast.instance.consume();
      expect(result!.$1, 'Yeni');
      expect(result.$2, false);
    });
  });
}
