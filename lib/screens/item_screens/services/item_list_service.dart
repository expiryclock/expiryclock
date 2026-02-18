// external
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// internal
import 'package:expiryclock/core/models/expiry_item.dart';
import 'package:expiryclock/core/data/item_repository.dart';
import 'package:expiryclock/screens/item_screens/models/sort_option.dart';

/// 아이템 리스트 화면의 비즈니스 로직을 담당하는 서비스
class ItemListService {
  final ItemRepository _repository;
  final ImagePicker _picker;

  ItemListService(this._repository) : _picker = ImagePicker();

  /// ValueNotifier를 가져옵니다
  ValueNotifier<int> get versionNotifier => _repository.version;

  /// 모든 아이템을 가져옵니다
  List<ExpiryItem> getAllItems({SortOption? sortOption}) {
    final items = _repository.getAll();

    if (sortOption == null) {
      return items;
    }

    return _sortItems(items, sortOption);
  }

  /// 아이템 리스트를 정렬합니다
  List<ExpiryItem> _sortItems(List<ExpiryItem> items, SortOption sortOption) {
    final sortedItems = List<ExpiryItem>.from(items);

    switch (sortOption) {
      case SortOption.expiryDateAsc:
        sortedItems.sort(
          (a, b) => a.expiryDateMillis.compareTo(b.expiryDateMillis),
        );
        break;
      case SortOption.expiryDateDesc:
        sortedItems.sort(
          (a, b) => b.expiryDateMillis.compareTo(a.expiryDateMillis),
        );
        break;
      case SortOption.nameAsc:
        sortedItems.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortOption.nameDesc:
        sortedItems.sort((a, b) => b.name.compareTo(a.name));
        break;
      case SortOption.registeredDateDesc:
        sortedItems.sort(
          (a, b) => b.registeredAtMillis.compareTo(a.registeredAtMillis),
        );
        break;
      case SortOption.registeredDateAsc:
        sortedItems.sort(
          (a, b) => a.registeredAtMillis.compareTo(b.registeredAtMillis),
        );
        break;
    }

    return sortedItems;
  }

  /// 아이템을 삭제합니다
  Future<void> deleteItem(String itemId) async {
    await _repository.remove(itemId);
  }

  /// 갤러리에서 이미지를 선택합니다
  Future<String?> pickImageFromGallery() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      return pickedFile?.path;
    } catch (e) {
      rethrow;
    }
  }

  /// 아이템 등록 화면으로 이동합니다
  static void navigateToRegister(BuildContext context, String imagePath) {
    Navigator.of(context).pushNamed('/regist', arguments: imagePath);
  }

  /// 카메라 화면으로 이동합니다
  static void navigateToCamera(BuildContext context) {
    Navigator.of(context).pushNamed('/camera');
  }

  /// 설정 화면으로 이동합니다
  static void navigateToSettings(BuildContext context) {
    Navigator.of(context).pushNamed('/settings');
  }

  /// 아이템 상세 화면으로 이동합니다
  static void navigateToDetail(BuildContext context, ExpiryItem item) {
    Navigator.of(context).pushNamed('/detail', arguments: item);
  }
}
