// external
import 'package:flutter/material.dart';

// internal
import 'package:expiryclock/core/models/expiry_item.dart';
import 'package:expiryclock/core/data/item_repository.dart';
import 'package:expiryclock/core/data/notification_settings_repository.dart';
import 'package:expiryclock/screens/settings/services/notification_service.dart';

/// 아이템 상세 화면의 비즈니스 로직을 담당하는 서비스
class ItemDetailService {
  final ItemRepository _repository;

  ItemDetailService(this._repository);

  /// 아이템을 저장하고 알림을 스케줄링합니다
  Future<void> saveItem({
    required ExpiryItem? existingItem,
    required String name,
    required String category,
    required DateTime expiryDate,
    required int notifyBeforeDays,
    required String memo,
    required int quantity,
  }) async {
    final now = DateTime.now();

    // 새로운 Item 인스턴스 생성 (expiryDate는 생성자에서만 설정 가능)
    final updatedItem = ExpiryItem.fromDateTime(
      id: existingItem?.id ?? now.millisecondsSinceEpoch.toString(),
      images: existingItem?.images ?? const [],
      name: name,
      category: category,
      expiryDate: expiryDate,
      registeredAt: existingItem?.registeredAt ?? now,
      notifyBeforeDays: notifyBeforeDays,
      memo: memo,
      quantity: quantity,
    );

    await _repository.upsert(updatedItem);

    // 알림 설정 가져오기
    final notificationSettings = await NotificationSettingsRepository()
        .getSettings();

    // 알림이 활성화되어 있을 때만 스케줄링
    if (notificationSettings.isEnabled) {
      await NotificationService.schedule(
        notifyBeforeDays,
        expiryDate,
        updatedItem.name,
        notificationHour: notificationSettings.notificationHour,
        notificationMinute: notificationSettings.notificationMinute,
      );
    } else {
      // 알림이 비활성화되어 있으면 기존 알림 취소
      await NotificationService.cancel(updatedItem.name);
    }
  }

  /// 아이템 목록 화면으로 이동합니다
  static void navigateToList(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/list',
      (route) => route.settings.name == '/list',
    );
  }
}
