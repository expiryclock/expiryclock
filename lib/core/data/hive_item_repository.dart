// external
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

// internal
import 'package:expiryclock/core/models/expiry_item.dart';
import 'package:expiryclock/shared/services/image_storage_service.dart';

import 'item_repository.dart';

/// Hive를 사용한 Item 저장소 구현
class HiveItemRepository implements ItemRepository {
  HiveItemRepository();

  static const String _boxName = 'expiry_items_box';

  Box<ExpiryItem>? _box;
  final ValueNotifier<int> _version = ValueNotifier<int>(0);

  @override
  ValueNotifier<int> get version => _version;

  /// Hive 아이템 DB 초기화 (앱 시작 시 호출)
  Future<void> init() async {
    _box = await Hive.openBox<ExpiryItem>(_boxName);
  }

  Box<ExpiryItem> get _safeBox {
    if (_box == null || !_box!.isOpen) {
      throw StateError('HiveItemRepository가 초기화되지 않았습니다. init()을 먼저 호출하세요.');
    }
    return _box!;
  }

  @override
  List<ExpiryItem> getAll() {
    return _safeBox.values.toList();
  }

  @override
  ExpiryItem? getById(String id) {
    return _safeBox.get(id);
  }

  @override
  Future<void> upsert(ExpiryItem item) async {
    // ID를 키로 사용하여 저장
    await _safeBox.put(item.id, item);
    _version.value++;
  }

  @override
  Future<void> remove(String id) async {
    final item = getById(id);
    if (item != null) {
      // 연관된 이미지 파일도 삭제
      await ImageStorageService.instance.deleteImages(item.images);

      // DB에서 삭제
      await _safeBox.delete(id);
      _version.value++;
    }
  }

  /// 모든 데이터 삭제 (테스트용)
  Future<void> clear() async {
    // 모든 이미지 파일 삭제
    for (final item in getAll()) {
      await ImageStorageService.instance.deleteImages(item.images);
    }

    await _safeBox.clear();
    _version.value++;
  }

  /// 저장소 닫기
  Future<void> close() async {
    await _box?.close();
  }
}
