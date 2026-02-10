// external
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

// internal
import 'package:expiryclock/screens/camera/camera_screen.dart';
import 'package:expiryclock/screens/item_management/item_register_screen.dart';
import 'package:expiryclock/screens/item_management/item_list_screen.dart';
import 'package:expiryclock/screens/item_management/item_detail_screen.dart';
import 'package:expiryclock/screens/settings/settings_screen.dart';
import 'package:expiryclock/core/models/expiry_item.dart';
import 'package:expiryclock/core/constants/start_screen.dart';
import 'package:expiryclock/core/data/start_screen_settings_repository.dart';

class ExpiryClockApp extends StatelessWidget {
  const ExpiryClockApp({super.key, required this.cameras});

  final List<CameraDescription> cameras;

  @override
  Widget build(BuildContext context) {
    // 시작 화면 설정 가져오기
    final startScreen = StartScreenSettingsRepository.instance.getStartScreen();

    // 시작 화면 결정
    final Widget homeWidget;
    if (cameras.isEmpty) {
      homeWidget = const _NoCameraScreen();
    } else if (startScreen == StartScreen.itemList) {
      homeWidget = const ItemListScreen();
    } else {
      homeWidget = HomeScreen(camera: cameras.first);
    }

    return MaterialApp(
      title: 'Expiration Clock',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      home: homeWidget,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/regist':
            final imagePath = settings.arguments as String?;
            return MaterialPageRoute(
              builder: (_) =>
                  CaptureReviewScreen(imagePath: imagePath ?? 'mock:image'),
            );

          case '/list':
            return MaterialPageRoute(builder: (_) => const ItemListScreen());

          case '/camera':
            if (cameras.isEmpty) {
              return MaterialPageRoute(builder: (_) => const _NoCameraScreen());
            }
            return MaterialPageRoute(
              builder: (_) => HomeScreen(camera: cameras.first),
            );

          case '/detail':
            final item = settings.arguments as ExpiryItem?;
            return MaterialPageRoute(
              builder: (_) => ItemDetailScreen(item: item),
            );

          case '/settings':
            return MaterialPageRoute(builder: (_) => const SettingsScreen());

          default:
            return null;
        }
      },
    );
  }
}

// 카메라가 전혀 없는 기기/에뮬레이터 대비용 간단 화면
class _NoCameraScreen extends StatelessWidget {
  const _NoCameraScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          '사용 가능한 카메라가 없습니다.',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
