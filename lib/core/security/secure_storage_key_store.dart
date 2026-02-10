// external
import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// internal
import 'key_store.dart';

// secure storage의 key를 가져오도록 하는 service class
class SecureStorageKeyStore implements KeyStore {
  static final SecureStorageKeyStore _instance =
      SecureStorageKeyStore._internal();
  factory SecureStorageKeyStore() => _instance;
  SecureStorageKeyStore._internal();

  final FlutterSecureStorage _storage = FlutterSecureStorage();
  // 키가 변경되었을 경우, 실시간으로 알려주기 위함
  final _changes = StreamController<KeyChange>.broadcast();

  @override
  Future<void> save({required String name, required String value}) async {
    final existed = await _storage.containsKey(key: name);
    await _storage.write(key: name, value: value);
    _changes.add(
      KeyChange(
        name: name,
        type: existed ? KeyChangeType.updated : KeyChangeType.created,
      ),
    );
  }

  @override
  Future<String?> read(String name) => _storage.read(key: name);

  @override
  Future<void> delete(String name) async {
    final existed = await _storage.containsKey(key: name);
    await _storage.delete(key: name);
    if (existed) {
      _changes.add(KeyChange(name: name, type: KeyChangeType.deleted));
    }
  }

  @override
  Stream<KeyChange> get changes => _changes.stream;

  @override
  Future<void> dispose() async {
    await _changes.close();
  }
}
