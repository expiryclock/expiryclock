// external
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// internal
import 'package:expiryclock/core/models/expiry_item.dart';
import 'package:expiryclock/core/data/item_repository.dart';

/// 아이템 리스트 화면의 비즈니스 로직을 담당하는 서비스
class ItemListService {
  final ItemRepository _repository;
  final ImagePicker _picker;

  ItemListService(this._repository) : _picker = ImagePicker();

  /// ValueNotifier를 가져옵니다
  ValueNotifier<int> get versionNotifier => _repository.version;

  /// 모든 아이템을 가져옵니다
  List<ExpiryItem> getAllItems() {
    return _repository.getAll();
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
