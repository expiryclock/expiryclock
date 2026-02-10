// external
import 'package:expiryclock/core/constants/start_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';

// internal
import 'package:expiryclock/core/models/app_settings.dart';

class StartScreenSettingsRepository {
  static const String _boxName = 'start_screen_settings';
  static const String _key = 'singleton';

  static final StartScreenSettingsRepository instance =
      StartScreenSettingsRepository._();
  StartScreenSettingsRepository._();

  Box<StartScreenSettings>? _box;

  /// Hive Box 초기화
  Future<void> init() async {
    await Hive.initFlutter();

    // Adapter 등록
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(StartScreenSettingsAdapter());
    }

    _box = await Hive.openBox<StartScreenSettings>(_boxName);

    // 기본값 설정 (처음 실행 시)
    if (_box!.get(_key) == null) {
      await _box!.put(_key, StartScreenSettings.defaults());
    }
  }

  /// 현재 설정 가져오기
  StartScreenSettings getSettings() {
    return _box?.get(_key) ?? StartScreenSettings.defaults();
  }

  /// 설정 업데이트
  Future<void> updateSettings(StartScreenSettings settings) async {
    await _box?.put(_key, settings);
  }

  /// 시작 화면 설정 업데이트
  Future<void> updateStartScreen(StartScreen screen) async {
    final current = getSettings();
    await updateSettings(current.copyWith(startScreen: screen));
  }

  /// 시작 화면 가져오기
  StartScreen getStartScreen() {
    return getSettings().startScreen;
  }
}
