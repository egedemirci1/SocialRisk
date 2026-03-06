import 'package:flutter_test/flutter_test.dart';

abstract class UserRepository {
  Future<String> fetchUserName();
}

class FakeUserRepository implements UserRepository {
  @override
  Future<String> fetchUserName() async {
    return "Test User";
  }
}

void main() {
  group('FakeUserRepository - Unit Tests', () {
    late UserRepository repository;

    setUp(() {
      repository = FakeUserRepository();
    });

    test('fetchUserName doğru kullanıcı adını döndürmeli', () async {
      // Arrange (Hazırlık setup içinde yapıldı)
      
      // Act
      final result = await repository.fetchUserName();
      
      // Assert
      expect(result, "Test User");
    });
  });
}
