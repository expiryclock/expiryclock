/// 키 변경 유형
enum KeyChangeType { created, updated, deleted }

/// 키 변경 이벤트 (민감값은 포함하지 않음)
class KeyChange {
  final String name;
  final KeyChangeType type;
  final DateTime at;
  KeyChange({required this.name, required this.type, DateTime? at})
    : at = at ?? DateTime.now();
}

/// 키 CRUD 인터페이스 (스토리지 무관)
abstract class KeyStore {
  /// 키 저장(존재하면 업데이트)
  Future<void> save({required String name, required String value});

  /// 키 조회(없으면 null)
  Future<String?> read(String name);

  /// 키 삭제(없으면 no-op)
  Future<void> delete(String name);

  /// 키 변경 스트림(생성/업데이트/삭제)
  Stream<KeyChange> get changes;

  /// 모든 리소스 정리(스트림 닫기 등)
  Future<void> dispose();
}
