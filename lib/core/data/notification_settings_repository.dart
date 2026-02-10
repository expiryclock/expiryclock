// external
import 'package:hive_flutter/hive_flutter.dart';

// internal
import 'package:expiryclock/core/models/app_settings.dart';

class NotificationSettingsRepository {
  static const String _boxName = 'notification_settings';
  static const String _settingsKey = 'settings';

  Box<NotificationSettings>? _box;

  /// 저장소 초기화
  Future<void> initialize() async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox<NotificationSettings>(_boxName);
    }
  }

  /// 알림 설정 가져오기
  Future<NotificationSettings> getSettings() async {
    await initialize();
    return _box!.get(_settingsKey) ?? NotificationSettings();
  }

  /// 알림 설정 저장
  Future<void> saveSettings(NotificationSettings settings) async {
    await initialize();
    await _box!.put(_settingsKey, settings);
  }

  /// 알림 설정 업데이트
  Future<void> updateSettings({
    int? notificationHour,
    int? notificationMinute,
    bool? isEnabled,
  }) async {
    final currentSettings = await getSettings();
    final updatedSettings = currentSettings.copyWith(
      notificationHour: notificationHour,
      notificationMinute: notificationMinute,
      isEnabled: isEnabled,
    );
    await saveSettings(updatedSettings);
  }

  /// 알림 설정 스트림
  Stream<NotificationSettings> watchSettings() async* {
    await initialize();
    yield await getSettings();
    yield* _box!.watch(key: _settingsKey).map((event) {
      return event.value as NotificationSettings? ?? NotificationSettings();
    });
  }

  /// 저장소 닫기
  Future<void> close() async {
    await _box?.close();
  }
}
