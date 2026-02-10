import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

/// 카메라 권한이 거부된 경우 표시할 앱
class CameraPermissionDeniedApp extends StatelessWidget {
  const CameraPermissionDeniedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '만료기한 관리',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.camera_alt_outlined,
                  size: 80,
                  color: Colors.grey,
                ),
                const SizedBox(height: 24),
                const Text(
                  '카메라 권한이 필요합니다',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  '이 앱은 만료기한을 촬영하여 관리하는 앱입니다.\n카메라 권한 없이는 앱을 사용할 수 없습니다.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () {
                    // 앱 종료
                    SystemNavigator.pop();
                  },
                  icon: const Icon(Icons.close),
                  label: const Text('앱 종료'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () async {
                    // 설정 화면으로 이동
                    await openAppSettings();
                  },
                  icon: const Icon(Icons.settings),
                  label: const Text('설정에서 권한 허용하기'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
