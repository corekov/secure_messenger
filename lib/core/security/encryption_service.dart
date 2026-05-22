import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../storage/secure_storage_service.dart';

part 'encryption_service.g.dart';

class EncryptionService {
  final SecureStorageService _storage;
  final X25519 _keyExchangeAlgorithm = X25519();
  final Chacha20 _encryptionAlgorithm = Chacha20.poly1305Aead();

  SimpleKeyPair? _keyPair;

  EncryptionService(this._storage);

  /// Initialize keys. If none exist in storage, generate and store new ones.
  Future<void> initialize() async {
    final privKeyBase64 = await _storage.getPrivateKey();
    final pubKeyBase64 = await _storage.getPublicKey();

    if (privKeyBase64 == null || pubKeyBase64 == null) {
      _keyPair = await _keyExchangeAlgorithm.newKeyPair();
      
      final privBytes = await _keyPair!.extractPrivateKeyBytes();
      final pubBytes = (await _keyPair!.extractPublicKey()).bytes;

      await _storage.saveKeyPair(
        privateKey: base64Encode(privBytes),
        publicKey: base64Encode(pubBytes),
      );
    } else {
      _keyPair = SimpleKeyPairData(
        base64Decode(privKeyBase64),
        publicKey: SimplePublicKey(
          base64Decode(pubKeyBase64),
          type: KeyPairType.x25519,
        ),
        type: KeyPairType.x25519,
      );
    }
  }

  /// Get the current user's public key to share with the server/peers.
  Future<String> getPublicKeyBase64() async {
    if (_keyPair == null) await initialize();
    final pubBytes = (await _keyPair!.extractPublicKey()).bytes;
    return base64Encode(pubBytes);
  }

  /// Derives a shared secret key with a peer's public key
  Future<SecretKey> _deriveSharedSecret(String peerPublicKeyBase64) async {
    if (_keyPair == null) await initialize();
    
    final peerPublicKey = SimplePublicKey(
      base64Decode(peerPublicKeyBase64),
      type: KeyPairType.x25519,
    );

    return await _keyExchangeAlgorithm.sharedSecretKey(
      keyPair: _keyPair!,
      remotePublicKey: peerPublicKey,
    );
  }

  /// Encrypts a plaintext message for a specific peer
  Future<String> encryptMessage(String plaintext, String peerPublicKeyBase64) async {
    final sharedSecret = await _deriveSharedSecret(peerPublicKeyBase64);
    
    final secretBox = await _encryptionAlgorithm.encrypt(
      utf8.encode(plaintext),
      secretKey: sharedSecret,
    );

    // Concatenate nonce + mac + ciphertext
    final combined = [
      ...secretBox.nonce,
      ...secretBox.mac.bytes,
      ...secretBox.cipherText,
    ];

    return base64Encode(combined);
  }

  /// Decrypts a ciphertext message from a specific peer
  Future<String> decryptMessage(String combinedBase64, String peerPublicKeyBase64) async {
    final sharedSecret = await _deriveSharedSecret(peerPublicKeyBase64);
    
    final combined = base64Decode(combinedBase64);
    
    // Extract nonce (12 bytes for ChaCha20), mac (16 bytes), and ciphertext
    final nonce = combined.sublist(0, 12);
    final macBytes = combined.sublist(12, 28);
    final cipherText = combined.sublist(28);

    final secretBox = SecretBox(
      cipherText,
      nonce: nonce,
      mac: Mac(macBytes),
    );

    final clearTextBytes = await _encryptionAlgorithm.decrypt(
      secretBox,
      secretKey: sharedSecret,
    );

    return utf8.decode(clearTextBytes);
  }
}

@riverpod
EncryptionService encryptionService(Ref ref) {
  final storage = ref.watch(secureStorageServiceProvider);
  return EncryptionService(storage);
}
