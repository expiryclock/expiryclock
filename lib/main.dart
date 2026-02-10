// external
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';

// internal
import 'core/app/hive_initializer.dart';
import 'core/app/app.dart';
import 'core/app/camera_permission_denied_app.dart';
import 'core/data/item_repository.dart';
import 'core/data/hive_item_repository.dart';
import 'shared/ai/clients/openai.dart';
import 'shared/ai/clients/openrouter.dart';
import 'shared/ai/clients/google.dart';
import 'shared/services/prompt_loader_service.dart';
import 'screens/settings/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 카메라 권한 확인 및 요청
  final cameraStatus = await Permission.camera.status;

  if (cameraStatus.isDenied) {
    // 권한이 거부된 경우 요청
    final result = await Permission.camera.request();

    if (result.isDenied || result.isPermanentlyDenied) {
      // 권한이 거부되었거나 영구적으로 거부된 경우
      runApp(const CameraPermissionDeniedApp());
      return;
    }
  } else if (cameraStatus.isPermanentlyDenied) {
    // 이미 영구적으로 거부된 경우
    runApp(const CameraPermissionDeniedApp());
    return;
  }

  // 권한이 승인된 경우에만 카메라 초기화
  final cameras = await availableCameras();

  // Hive DB 초기화
  await HiveInitializer.init();

  // 아이템 DB Repo 초기화
  final itemRepository = HiveItemRepository();
  await itemRepository.init();

  // 알림 서비스 초기화
  await NotificationService.initialize();

  // AI 클라이언트 및 프롬프트 초기화
  // 프롬프트는 앱 시작 시 메모리에 로드
  // 로딩 시간을 오래가져가지 않도록 하기 위해 await 사용하지 않음
  Future.wait([
    PromptLoaderService().initialize(),
    OpenAI.initialize(),
    OpenRouter.initialize(),
    Gemini.initialize(),
  ]);

  runApp(
    ProviderScope(
      overrides: [itemRepositoryProvider.overrideWithValue(itemRepository)],
      child: ExpiryClockApp(cameras: cameras),
    ),
  );
}
