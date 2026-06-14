import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:cryptography/cryptography.dart';
import 'package:secure_messenger/core/security/encryption_service.dart';
import 'package:secure_messenger/core/storage/secure_storage_service.dart';

class FakeSecureStorageService implements SecureStorageService {
  String? _privateKey;
  String? _publicKey;

  @override
  Future<String?> getPrivateKey() async => _privateKey;

  @override
  Future<String?> getPublicKey() async => _publicKey;

  @override
  Future<void> saveKeyPair({
    required String privateKey,
    required String publicKey,
  }) async {
    _privateKey = privateKey;
    _publicKey = publicKey;
  }

  // Implementing other required methods with no-ops for this test
  @override Future<void> saveToken(String token) async {}
  @override Future<String?> getToken() async => null;
  @override Future<void> deleteToken() async {}
  @override Future<void> savePin(String pin) async {}
  @override Future<String?> getPin() async => null;
  @override Future<void> deletePin() async {}
  @override Future<void> saveRefreshToken(String token) async {}
  @override Future<String?> getRefreshToken() async => null;
  @override Future<void> deleteRefreshToken() async {}
  @override Future<void> clearAll() async {}
  
  @override Future<void> clearTokens() async {}
  @override Future<String?> getAccessToken() async => null;
  @override Future<String?> getDeviceFingerprint() async => null;
  @override Future<void> saveAccessToken(String token) async {}
  @override Future<void> saveDeviceFingerprint(String fp) async {}
}

void main() {
  group('EncryptionService Tests', () {
    late EncryptionService encryptionService1;
    late EncryptionService encryptionService2;
    late FakeSecureStorageService storage1;
    late FakeSecureStorageService storage2;

    setUp(() async {
      storage1 = FakeSecureStorageService();
      storage2 = FakeSecureStorageService();
      
      encryptionService1 = EncryptionService(storage1);
      encryptionService2 = EncryptionService(storage2);

      await encryptionService1.initialize();
      await encryptionService2.initialize();
    });

    test('initialize generates and stores keys', () async {
      final privKey = await storage1.getPrivateKey();
      final pubKey = await storage1.getPublicKey();

      expect(privKey, isNotNull);
      expect(pubKey, isNotNull);
    });

    test('getPublicKeyBase64 returns correct public key', () async {
      final pubKey = await encryptionService1.getPublicKeyBase64();
      final storedPubKey = await storage1.getPublicKey();

      expect(pubKey, equals(storedPubKey));
    });

    test('encrypt and decrypt message successfully', () async {
      final message = 'Hello, Secret World!';
      
      final pubKey1 = await encryptionService1.getPublicKeyBase64();
      final pubKey2 = await encryptionService2.getPublicKeyBase64();

      // User 1 encrypts message for User 2
      final encryptedBase64 = await encryptionService1.encryptMessage(message, pubKey2);

      // Verify that it's actually encrypted (not just plaintext)
      expect(encryptedBase64, isNot(equals(message)));
      expect(encryptedBase64, isNot(contains(message)));

      // User 2 decrypts message from User 1
      final decrypted = await encryptionService2.decryptMessage(encryptedBase64, pubKey1);

      expect(decrypted, equals(message));
    });

    test('decrypting with wrong public key fails', () async {
      final message = 'Top Secret';
      
      final pubKey2 = await encryptionService2.getPublicKeyBase64();
      
      // We need a 3rd user to provide a wrong key
      final storage3 = FakeSecureStorageService();
      final encryptionService3 = EncryptionService(storage3);
      await encryptionService3.initialize();
      final pubKey3 = await encryptionService3.getPublicKeyBase64();

      final encryptedBase64 = await encryptionService1.encryptMessage(message, pubKey2);

      // User 2 tries to decrypt, but provides User 3's public key instead of User 1's
      expect(
        () async => await encryptionService2.decryptMessage(encryptedBase64, pubKey3),
        throwsException,
      );
    });
  });
}
