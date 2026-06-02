import 'dart:convert';
import 'dart:io';
import 'package:cryptography/cryptography.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

class FileService {
  final Dio _dio;

  FileService(this._dio);

  /// Generates a random 256-bit AES-GCM key and returns it as a Base64 string.
  Future<String> generateSymmetricKey() async {
    final secretKey = await AesGcm.with256bits().newSecretKey();
    final keyBytes = await secretKey.extractBytes();
    return base64Encode(keyBytes);
  }

  /// Encrypts a file using AES-GCM 256-bit. Returns the path to the encrypted file.
  Future<String> encryptFile(String filePath, String base64Key) async {
    final keyBytes = base64Decode(base64Key);
    final secretKey = SecretKey(keyBytes);
    final cipher = AesGcm.with256bits();

    final fileBytes = await File(filePath).readAsBytes();
    
    // Encrypt
    final secretBox = await cipher.encrypt(
      fileBytes,
      secretKey: secretKey,
    );

    // Save encrypted bytes to a temp file
    final tempDir = await getTemporaryDirectory();
    final encryptedFilePath = p.join(tempDir.path, '${const Uuid().v4()}.enc');
    await File(encryptedFilePath).writeAsBytes(secretBox.concatenation());

    return encryptedFilePath;
  }

  /// Decrypts an encrypted file buffer using AES-GCM 256-bit.
  Future<List<int>> decryptFileBytes(List<int> encryptedBytes, String base64Key) async {
    final keyBytes = base64Decode(base64Key);
    final secretKey = SecretKey(keyBytes);
    final cipher = AesGcm.with256bits();

    final secretBox = SecretBox.fromConcatenation(
      encryptedBytes,
      nonceLength: cipher.nonceLength,
      macLength: cipher.macAlgorithm.macLength,
    );

    final decrypted = await cipher.decrypt(
      secretBox,
      secretKey: secretKey,
    );

    return decrypted;
  }

  /// Uploads an encrypted file to the backend. Returns the file ID.
  Future<String> uploadEncryptedFile(String encryptedFilePath) async {
    final file = File(encryptedFilePath);
    
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path,
        filename: p.basename(file.path),
      ),
      'encrypted_key': '', // Left empty, sent in E2EE payload instead
    });

    final response = await _dio.post('/files/upload', data: formData);
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.data['id'] as String;
    } else {
      throw Exception('Failed to upload file: ${response.statusCode}');
    }
  }

  /// Downloads and decrypts a file, saving it securely to app documents.
  Future<String> downloadAndDecryptFile(String fileId, String fileName, String base64Key) async {
    final response = await _dio.get(
      '/files/$fileId/download',
      options: Options(responseType: ResponseType.bytes),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to download file: ${response.statusCode}');
    }

    final encryptedBytes = response.data as List<int>;
    final decryptedBytes = await decryptFileBytes(encryptedBytes, base64Key);

    // Store in private app directory
    final appDir = await getApplicationDocumentsDirectory();
    final safeFileName = '${const Uuid().v4()}_$fileName';
    final localPath = p.join(appDir.path, safeFileName);
    
    await File(localPath).writeAsBytes(decryptedBytes);
    return localPath;
  }
}
