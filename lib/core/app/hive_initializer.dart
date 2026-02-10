// external
import 'package:expiryclock/core/models/app_settings.dart';
import 'package:expiryclock/core/models/expiry_item.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveInitializer {
  HiveInitializer._();

  static Future<void> init() async {
    await Hive.initFlutter();

    _registerAdapters();
  }

  static void _registerAdapters() {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ExpiryItemAdapter());
    }

    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(NotificationSettingsAdapter());
    }

    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(StartScreenSettingsAdapter());
    }
  }
}
