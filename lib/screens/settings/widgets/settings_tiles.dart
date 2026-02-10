// external
import 'package:expiryclock/core/constants/start_screen.dart';
import 'package:flutter/material.dart';

/// 시작 화면 설정 타일
class StartScreenTile extends StatelessWidget {
  final StartScreen currentStartScreen;
  final VoidCallback onTap;

  const StartScreenTile({
    required this.currentStartScreen,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.home),
      title: const Text('시작 화면'),
      subtitle: Text(
        currentStartScreen == StartScreen.camera ? '카메라 화면' : '아이템 리스트',
      ),
      onTap: onTap,
    );
  }
}

/// 알림 설정 타일
class NotificationSettingsTile extends StatelessWidget {
  final VoidCallback onTap;

  const NotificationSettingsTile({
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.notifications),
      title: const Text('알림 설정'),
      subtitle: const Text('만료기한 알림 설정'),
      onTap: onTap,
    );
  }
}

/// API 키 관리 타일
class ApiKeyTile extends StatelessWidget {
  final VoidCallback onTap;

  const ApiKeyTile({
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.key),
      title: const Text('키 관리'),
      subtitle: const Text('AI API 키 관리'),
      onTap: onTap,
    );
  }
}

/// 데이터 내보내기 타일
class ExportDataTile extends StatelessWidget {
  final VoidCallback onTap;

  const ExportDataTile({
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.upload),
      title: const Text('데이터 내보내기'),
      subtitle: const Text('아이템 데이터를 파일로 내보내기 (이미지 제외)'),
      onTap: onTap,
    );
  }
}

/// 데이터 가져오기 타일
class ImportDataTile extends StatelessWidget {
  final VoidCallback onTap;

  const ImportDataTile({
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.download),
      title: const Text('데이터 가져오기'),
      subtitle: const Text('파일에서 아이템 데이터 가져오기'),
      onTap: onTap,
    );
  }
}

/// 앱 정보 타일
class AppInfoTile extends StatelessWidget {
  final VoidCallback onTap;

  const AppInfoTile({
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.info),
      title: const Text('앱 정보'),
      subtitle: const Text('버전 0.0.1'),
      onTap: onTap,
    );
  }
}
