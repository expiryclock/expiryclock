// external
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// internal
import 'package:expiryclock/core/models/expiry_item.dart';

/// ItemRepository Provider (추상 타입 기준)
final itemRepositoryProvider = Provider<ItemRepository>((ref) {
  throw UnimplementedError('ItemRepository must be overridden');
});

/// Item 저장소 인터페이스
abstract class ItemRepository {
  /// 모든 아이템 조회
  List<ExpiryItem> getAll();

  /// ID로 아이템 조회
  ExpiryItem? getById(String id);

  /// 아이템 추가 또는 업데이트
  Future<void> upsert(ExpiryItem item);

  /// 아이템 삭제
  Future<void> remove(String id);

  /// 변경 사항을 감지할 수 있는 notifier
  ValueNotifier<int> get version;
}
