
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:encrypt/encrypt.dart' as enc;

class EncryptionService {
  static final EncryptionService _instance = EncryptionService._internal();
  factory EncryptionService() => _instance;
  EncryptionService._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  late enc.Key _key;
  late enc.IV _iv;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    // Try to retrieve existing key from secure storage
    final keyString = await _secureStorage.read(key: 'encryption_key');
    final ivString = await _secureStorage.read(key: 'encryption_iv');

    if (keyString != null && ivString != null) {
      _key = enc.Key.fromBase64(keyString);
      _iv = enc.IV.fromBase64(ivString);
    } else {
      // Generate new key and IV
      _key = enc.Key.fromSecureRandom(32); // 256-bit AES key
      _iv = enc.IV.fromSecureRandom(16);

      // Store securely
      await _secureStorage.write(key: 'encryption_key', value: _key.base64);
      await _secureStorage.write(key: 'encryption_iv', value: _iv.base64);
    }

    _initialized = true;
  }

  String encrypt(String plaintext) {
    if (!_initialized) throw Exception('EncryptionService not initialized');
    final encrypter = enc.Encrypter(enc.AES(_key, mode: enc.AESMode.cbc));
    final encrypted = encrypter.encrypt(plaintext, iv: _iv);
    return encrypted.base64;
  }

  String decrypt(String ciphertext) {
    if (!_initialized) throw Exception('EncryptionService not initialized');
    try {
      final encrypter = enc.Encrypter(enc.AES(_key, mode: enc.AESMode.cbc));
      final decrypted = encrypter.decrypt64(ciphertext, iv: _iv);
      return decrypted;
    } catch (e) {
      throw Exception('Decryption failed: $e');
    }
  }

  // Encrypt sensitive fields in a map (summary, keyIssues, notes)
  Map<String, dynamic> encryptCaseData(Map<String, dynamic> data) {
    final encrypted = Map<String, dynamic>.from(data);
    encrypted['summary'] = encrypt(data['summary'] ?? '');
    encrypted['key_issues'] = encrypt(data['key_issues'] ?? '');
    encrypted['notes'] = encrypt(data['notes'] ?? '');
    encrypted['is_encrypted'] = true;
    return encrypted;
  }

  // Decrypt sensitive fields
  Map<String, dynamic> decryptCaseData(Map<String, dynamic> data) {
    if (data['is_encrypted'] != true) return data;
    final decrypted = Map<String, dynamic>.from(data);
    try {
      decrypted['summary'] = decrypt(data['summary'] ?? '');
      decrypted['key_issues'] = decrypt(data['key_issues'] ?? '');
      decrypted['notes'] = decrypt(data['notes'] ?? '');
    } catch (e) {
      // Silently return encrypted data if decryption fails
      return data;
    }
    return decrypted;
  }
}
