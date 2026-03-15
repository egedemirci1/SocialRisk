import 'package:flutter_test/flutter_test.dart';
import 'package:social_risk/features/economy/domain/economy_exceptions.dart';

void main() {
  group('InsufficientBalanceException', () {
    test('varsayılan mesaj kullanılır', () {
      const e = InsufficientBalanceException();
      expect(e.message, 'Yetersiz bakiye.');
      expect(e.toString(), 'Yetersiz bakiye.');
    });
    test('özel mesaj kullanılır', () {
      const e = InsufficientBalanceException('Bakiye 100 altında.');
      expect(e.message, 'Bakiye 100 altında.');
      expect(e.toString(), 'Bakiye 100 altında.');
    });
  });

  group('AlreadyOwnedCosmeticException', () {
    test('varsayılan mesaj kullanılır', () {
      const e = AlreadyOwnedCosmeticException();
      expect(e.message, 'Bu eşyaya zaten sahipsiniz.');
      expect(e.toString(), 'Bu eşyaya zaten sahipsiniz.');
    });
    test('özel mesaj kullanılır', () {
      const e = AlreadyOwnedCosmeticException('Bu kozmetik zaten satın alındı.');
      expect(e.message, 'Bu kozmetik zaten satın alındı.');
      expect(e.toString(), 'Bu kozmetik zaten satın alındı.');
    });
  });

  group('UserNotFoundException', () {
    test('varsayılan mesaj kullanılır', () {
      const e = UserNotFoundException();
      expect(e.message, 'Kullanıcı bulunamadı.');
      expect(e.toString(), 'Kullanıcı bulunamadı.');
    });
    test('özel mesaj kullanılır', () {
      const e = UserNotFoundException('uid xyz bulunamadı.');
      expect(e.message, 'uid xyz bulunamadı.');
      expect(e.toString(), 'uid xyz bulunamadı.');
    });
  });

  group('EconomyException alt sınıfları', () {
    test('hepsi EconomyException ve Exception implement eder', () {
      expect(const InsufficientBalanceException(), isA<EconomyException>());
      expect(const InsufficientBalanceException(), isA<Exception>());
      expect(const AlreadyOwnedCosmeticException(), isA<EconomyException>());
      expect(const UserNotFoundException(), isA<EconomyException>());
    });
  });
}
