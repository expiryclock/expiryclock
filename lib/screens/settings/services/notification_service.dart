import 'package:flutter/material.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // 초기화 유무 판단하기 위함
  static bool _initialized = false;

  /// 알림 서비스 초기화
  static Future<void> initialize() async {
    if (_initialized) return;

    // 타임존 데이터 초기화
    // TODO: 현재 국내 시간으로 고정되어있는 부분을 추후 동적으로 변경할 것 인지 확인.
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Seoul'));

    // Android 설정
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // iOS 설정
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        // 알림 클릭 시 처리 (필요시 구현)
      },
    );

    // Android 13+ 알림 권한 요청
    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    _initialized = true;
  }

  /// 만료기한 알림 스케줄링
  /// [daysBefore]: 만료기한 며칠 전에 알림을 받을지
  /// [expiry]: 만료기한 날짜
  /// [title]: 아이템 이름
  /// [notificationHour]: 알림을 받을 시간 (0-23)
  /// [notificationMinute]: 알림을 받을 분 (0-59)
  static Future<void> schedule(
    int daysBefore,
    DateTime expiry,
    String title, {
    int notificationHour = 9,
    int notificationMinute = 0,
  }) async {
    if (!_initialized) {
      await initialize();
    }

    // 기존 알림 취소 (아이템 ID를 해시코드로 사용)
    final notificationId = title.hashCode;
    await _notifications.cancel(notificationId);

    // daysBefore가 0이면 알림 설정 안 함
    if (daysBefore <= 0) return;

    // 알림 시간 계산: 만료기한 - daysBefore일, 설정된 시간
    final notificationDate = DateTime(
      expiry.year,
      expiry.month,
      expiry.day - daysBefore,
      notificationHour,
      notificationMinute,
      0,
    );

    // 과거 시간이면 알림 설정 안 함
    if (notificationDate.isBefore(DateTime.now())) {
      return;
    }

    // 알림 상세 설정
    const androidDetails = AndroidNotificationDetails(
      'expiry_tracker_channel',
      '만료기한 알림',
      channelDescription: '아이템의 만료기한이 다가올 때 알림을 받습니다',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // 알림 스케줄링
    debugPrint('========== 알림 스케줄링 정보 ==========');
    debugPrint('notificationId: $notificationId');
    debugPrint('제목: 만료기한 알림');
    debugPrint('내용: $title의 만료기한이 ${daysBefore}일 남았습니다');
    debugPrint('알림 예정 시간: $notificationDate');
    debugPrint('TZ 알림 시간: ${tz.TZDateTime.from(notificationDate, tz.local)}');
    debugPrint('아이템 이름: $title');
    debugPrint('며칠 전 알림: ${daysBefore}일');
    debugPrint('만료 날짜: $expiry');
    debugPrint('=====================================');

    await _notifications.zonedSchedule(
      notificationId,
      '만료기한 알림',
      '$title의 만료기한이 ${daysBefore}일 남았습니다',
      tz.TZDateTime.from(notificationDate, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// 특정 알림 취소
  static Future<void> cancel(String itemName) async {
    final notificationId = itemName.hashCode;
    await _notifications.cancel(notificationId);
  }

  /// 모든 알림 취소
  static Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  /// 모든 아이템의 알림을 재스케줄링
  /// 알림 설정이 변경되었을 때 호출
  static Future<void> rescheduleAll({
    required List<dynamic> items,
    required int notificationHour,
    required int notificationMinute,
    required bool isEnabled,
  }) async {
    if (!_initialized) {
      await initialize();
    }

    // 모든 알림 취소
    await cancelAll();

    // 알림이 비활성화되어 있으면 여기서 종료
    if (!isEnabled) {
      return;
    }

    // 각 아이템에 대해 알림 재설정
    for (final item in items) {
      // Item 객체에서 필요한 정보 추출
      // getter를 통해 이미 올바른 타입이 반환되므로 캐스팅 불필요
      final name = item.name;
      final expiryDate = item.expiryDate;
      final notifyBeforeDays = item.notifyBeforeDays;

      // 알림 스케줄링
      await schedule(
        notifyBeforeDays,
        expiryDate,
        name,
        notificationHour: notificationHour,
        notificationMinute: notificationMinute,
      );
    }
  }

  // ========== 디버깅 및 테스트 기능 ==========

  /// 테스트 알림 즉시 전송 (5초 후)
  static Future<void> sendTestNotification({int delaySeconds = 5}) async {
    if (!_initialized) {
      await initialize();
    }

    final now = tz.TZDateTime.now(tz.local);
    final scheduledTime = now.add(Duration(seconds: delaySeconds));

    const androidDetails = AndroidNotificationDetails(
      'expiry_tracker_channel',
      '만료기한 알림',
      channelDescription: '아이템의 만료기한이 다가올 때 알림을 받습니다',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final nowUtc = DateTime.now().toUtc();
    final scheduledUtc = scheduledTime.toUtc();

    debugPrint('========== 테스트 알림 전송 (alarmClock 모드) ==========');
    debugPrint('알림 ID: 999999');
    debugPrint('--- 로컬 시간 ---');
    debugPrint('현재 시간 (TZ): $now');
    debugPrint('현재 시간 (DateTime): ${DateTime.now()}');
    debugPrint('예정 시간 (TZ): $scheduledTime');
    debugPrint('--- UTC 시간 ---');
    debugPrint('현재 시간 (UTC): $nowUtc');
    debugPrint('예정 시간 (UTC): $scheduledUtc');
    debugPrint('--- 기타 정보 ---');
    debugPrint('타임존: ${tz.local.name}');
    debugPrint('딜레이: ${delaySeconds}초');
    debugPrint(
      '시간 비교: now.isBefore(scheduledTime) = ${now.isBefore(scheduledTime)}',
    );
    debugPrint('시간 차이(초): ${scheduledTime.difference(now).inSeconds}');
    debugPrint('AndroidScheduleMode: exactAllowWhileIdle');
    debugPrint('====================================');

    try {
      await _notifications.zonedSchedule(
        999999, // 테스트용 고정 ID
        '테스트 알림 🔔',
        '알림이 정상적으로 작동합니다! (${delaySeconds}초 후 전송)',
        scheduledTime,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      debugPrint('✅ zonedSchedule 호출 완료');
    } catch (e) {
      debugPrint('❌ zonedSchedule 실패: $e');
      rethrow;
    }
  }

  /// 즉시 알림 표시 (지연 없음)
  static Future<void> showImmediateNotification() async {
    if (!_initialized) {
      await initialize();
    }

    const androidDetails = AndroidNotificationDetails(
      'expiry_tracker_channel',
      '만료기한 알림',
      channelDescription: '아이템의 만료기한이 다가올 때 알림을 받습니다',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    debugPrint('========== 즉시 알림 표시 ==========');
    debugPrint('알림 ID: 999998');
    debugPrint('==================================');

    await _notifications.show(
      999998,
      '즉시 테스트 알림 🔔',
      '알림이 즉시 표시되었습니다!',
      details,
    );
  }

  /// 예약된 알림 개수 확인
  static Future<int> getPendingNotificationCount() async {
    if (!_initialized) {
      await initialize();
    }

    final pendingNotifications = await _notifications
        .pendingNotificationRequests();

    debugPrint('========== 예약된 알림 목록 ==========');
    debugPrint('총 ${pendingNotifications.length}개의 예약된 알림');
    for (final notification in pendingNotifications) {
      debugPrint('ID: ${notification.id}, Title: ${notification.title}');
    }
    debugPrint('====================================');

    return pendingNotifications.length;
  }

  /// 알림 권한 확인 (Android)
  static Future<bool?> checkNotificationPermission() async {
    if (!_initialized) {
      await initialize();
    }

    final androidImpl = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidImpl != null) {
      final hasPermission = await androidImpl.areNotificationsEnabled();
      debugPrint('========== 알림 권한 확인 ==========');
      debugPrint('알림 권한: ${hasPermission == true ? "허용됨" : "거부됨"}');
      debugPrint('==================================');
      return hasPermission;
    }

    return null; // iOS는 런타임에 확인 불가
  }

  /// 알림 권한 요청
  static Future<bool?> requestNotificationPermission() async {
    if (!_initialized) {
      await initialize();
    }

    final androidImpl = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidImpl != null) {
      final granted = await androidImpl.requestNotificationsPermission();
      debugPrint('========== 알림 권한 요청 ==========');
      debugPrint('권한 요청 결과: ${granted == true ? "허용됨" : "거부됨"}');
      debugPrint('==================================');
      return granted;
    }

    return null;
  }

  /// 정확한 알람 권한 확인 (Android 12+에서 예약 알림에 필요)
  static Future<bool?> checkExactAlarmPermission() async {
    if (!_initialized) {
      await initialize();
    }

    final androidImpl = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidImpl != null) {
      final canSchedule = await androidImpl.canScheduleExactNotifications();
      debugPrint('========== 정확한 알람 권한 확인 ==========');
      debugPrint('예약 알림 권한: ${canSchedule == true ? "허용됨" : "거부됨"}');
      debugPrint('이 권한이 없으면 zonedSchedule이 작동하지 않습니다!');
      debugPrint('========================================');
      return canSchedule;
    }

    return null; // iOS는 확인 불필요
  }

  /// 정확한 알람 권한 요청 (설정 화면으로 이동)
  static Future<bool?> requestExactAlarmPermission() async {
    if (!_initialized) {
      await initialize();
    }

    final androidImpl = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidImpl != null) {
      // Android 12+ (API 31+)에서는 설정 화면으로 이동
      final result = await androidImpl.requestExactAlarmsPermission();
      debugPrint('========== 정확한 알람 권한 요청 ==========');
      debugPrint('권한 요청 결과: ${result == true ? "허용됨" : "거부됨"}');
      debugPrint('========================================');
      return result;
    }

    return null;
  }
}
