import 'package:expiryclock/core/constants/start_screen.dart';
import 'package:hive/hive.dart';

part 'app_settings.g.dart';

@HiveType(typeId: 1)
class NotificationSettings extends HiveObject {
  /// 알림을 받을 시간 (0-23시, 기본값: 18시)
  @HiveField(1)
  int notificationHour;

  /// 알림을 받을 분 (0-59분, 기본값: 0분)
  @HiveField(2)
  int notificationMinute;

  /// 알림 활성화 여부 (기본값: true)
  @HiveField(3)
  bool isEnabled;

  NotificationSettings({
    this.notificationHour = 18,
    this.notificationMinute = 0,
    this.isEnabled = true,
  });

  /// 알림 시간을 TimeOfDay 형식으로 반환
  String get formattedTime {
    final hour = notificationHour.toString().padLeft(2, '0');
    final minute = notificationMinute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// 복사본 생성
  NotificationSettings copyWith({
    int? notificationHour,
    int? notificationMinute,
    bool? isEnabled,
  }) {
    return NotificationSettings(
      notificationHour: notificationHour ?? this.notificationHour,
      notificationMinute: notificationMinute ?? this.notificationMinute,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}

@HiveType(typeId: 2)
class StartScreenSettings extends HiveObject {
  StartScreenSettings({required this.startScreenName});

  /// Hive에는 안전한 primitive(String)로 저장
  @HiveField(0)
  String startScreenName;

  /// 앱에서는 enum으로 사용
  StartScreen get startScreen => StartScreen.values.byName(startScreenName);
  set startScreen(StartScreen v) => startScreenName = v.name;

  factory StartScreenSettings.defaults() =>
      StartScreenSettings(startScreenName: StartScreen.camera.name);

  /// 복사본 생성
  StartScreenSettings copyWith({StartScreen? startScreen}) {
    return StartScreenSettings(
      startScreenName: startScreen?.name ?? startScreenName,
    );
  }
}
