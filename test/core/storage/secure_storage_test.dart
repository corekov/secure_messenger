import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mocktail/mocktail.dart';
import 'package:secure_messenger/core/storage/secure_storage_service.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  group('SecureStorageService Tests', () {
    late SecureStorageService storageService;
    late MockFlutterSecureStorage mockStorage;

    setUp(() {
      mockStorage = MockFlutterSecureStorage();
      storageService = SecureStorageService(mockStorage);
    });

    test('saveKeyPair successfully stores keys', () async {
      final privateKey = 'test_private_key';
      final publicKey = 'test_public_key';

      when(() => mockStorage.write(key: 'private_key', value: privateKey))
          .thenAnswer((_) async {});
      when(() => mockStorage.write(key: 'public_key', value: publicKey))
          .thenAnswer((_) async {});

      await storageService.saveKeyPair(
        privateKey: privateKey,
        publicKey: publicKey,
      );

      verify(() => mockStorage.write(key: 'private_key', value: privateKey)).called(1);
      verify(() => mockStorage.write(key: 'public_key', value: publicKey)).called(1);
    });

    test('getPrivateKey and getPublicKey retrieve correctly', () async {
      when(() => mockStorage.read(key: 'private_key'))
          .thenAnswer((_) async => 'stored_priv');
      when(() => mockStorage.read(key: 'public_key'))
          .thenAnswer((_) async => 'stored_pub');

      final priv = await storageService.getPrivateKey();
      final pub = await storageService.getPublicKey();

      expect(priv, equals('stored_priv'));
      expect(pub, equals('stored_pub'));
    });

    test('savePin successfully hashes and stores PIN', () async {
      final pin = '1234';
      
      when(() => mockStorage.write(key: 'app_pin_hash', value: pin))
          .thenAnswer((_) async {});

      await storageService.savePin(pin);

      verify(() => mockStorage.write(key: 'app_pin_hash', value: pin)).called(1);
    });

    test('clearTokens clears all stored security tokens', () async {
      when(() => mockStorage.delete(key: any(named: 'key')))
          .thenAnswer((_) async {});

      await storageService.clearTokens();

      verify(() => mockStorage.delete(key: 'access_token')).called(1);
      verify(() => mockStorage.delete(key: 'refresh_token')).called(1);
      verify(() => mockStorage.delete(key: 'private_key')).called(1);
      verify(() => mockStorage.delete(key: 'public_key')).called(1);
    });
  });
}
