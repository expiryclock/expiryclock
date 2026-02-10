// external
import 'dart:io';
import 'package:expiryclock/core/constants/start_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';

// internal
import 'package:expiryclock/core/data/start_screen_settings_repository.dart';
import 'package:expiryclock/core/data/item_repository.dart';
import 'package:expiryclock/screens/settings/widgets/api_key_dialog.dart';
import 'package:expiryclock/screens/settings/widgets/start_screen_dialog.dart';
import 'package:expiryclock/screens/settings/widgets/settings_tiles.dart';
import 'package:expiryclock/screens/settings/notification_settings_screen.dart';
import 'package:expiryclock/screens/settings/services/data_import_export_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _settingsRepo = StartScreenSettingsRepository.instance;
  final _exportService = DataImportExportService.instance;

  /// 데이터 내보내기
  Future<void> _exportData() async {
    try {
      final repository = ref.read(itemRepositoryProvider);
      final itemCount = repository.getAll().length;

      if (itemCount == 0) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('내보낼 아이템이 없습니다.')));
        }
        return;
      }

      // 로딩 표시
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
        );
      }

      await _exportService.exportItems(repository);

      if (mounted) {
        Navigator.of(context).pop(); // 로딩 다이얼로그 닫기
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$itemCount개의 아이템을 내보냈습니다.')));
      }
    } catch (e) {
      if (mounted) {
        // 로딩 다이얼로그가 열려 있으면 닫기
        if (Navigator.canPop(context)) {
          Navigator.of(context).pop();
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('데이터 내보내기 실패: $e')));
      }
    }
  }

  /// 데이터 가져오기
  Future<void> _importData() async {
    try {
      // 파일 선택
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) {
        return; // 사용자가 취소함
      }

      final filePath = result.files.single.path;
      if (filePath == null) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('파일 경로를 찾을 수 없습니다.')));
        }
        return;
      }

      final file = File(filePath);
      final repository = ref.read(itemRepositoryProvider);

      // 덮어쓰기 확인 다이얼로그
      final shouldOverwrite = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('가져오기 옵션'),
          content: const Text(
            '이미 존재하는 아이템을 어떻게 처리할까요?\n\n'
            '• 건너뛰기: 기존 아이템은 유지하고 새 아이템만 추가\n'
            '• 덮어쓰기: 기존 아이템을 업데이트',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('건너뛰기'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('덮어쓰기'),
            ),
          ],
        ),
      );

      if (shouldOverwrite == null) {
        return; // 사용자가 취소함
      }

      // 로딩 표시
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
        );
      }

      // 가져오기 실행
      final ImportResult importResult;
      if (shouldOverwrite) {
        importResult = await _exportService.importItemsWithOverwrite(
          repository,
          file,
        );
      } else {
        importResult = await _exportService.importItems(repository, file);
      }

      if (mounted) {
        Navigator.of(context).pop(); // 로딩 다이얼로그 닫기

        // 결과 표시
        final message = StringBuffer();
        if (importResult.imported > 0) {
          message.write('새로 추가: ${importResult.imported}개');
        }
        if (importResult.updated > 0) {
          if (message.isNotEmpty) message.write('\n');
          message.write('업데이트: ${importResult.updated}개');
        }
        if (importResult.skipped > 0) {
          if (message.isNotEmpty) message.write('\n');
          message.write('건너뜀: ${importResult.skipped}개');
        }

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('가져오기 완료'),
            content: Text(message.toString()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('확인'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // 로딩 다이얼로그가 열려 있으면 닫기
        if (Navigator.canPop(context)) {
          Navigator.of(context).pop();
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('데이터 가져오기 실패: $e')));
      }
    }
  }

  /// 시작 화면 설정 처리
  Future<void> _handleStartScreenTap(StartScreen currentStartScreen) async {
    final selected = await showDialog<StartScreen>(
      context: context,
      builder: (context) =>
          StartScreenDialog(currentScreen: currentStartScreen),
    );
    if (selected != null && mounted) {
      await _settingsRepo.updateStartScreen(selected);
      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('시작 화면이 변경되었습니다. 앱을 재시작하면 적용됩니다.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentStartScreen = _settingsRepo.getStartScreen();

    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.grey.withValues(alpha: 0.5),
      ),
      body: ListView(
        children: [
          StartScreenTile(
            currentStartScreen: currentStartScreen,
            onTap: () => _handleStartScreenTap(currentStartScreen),
          ),
          const Divider(),
          NotificationSettingsTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationSettingsScreen(),
                ),
              );
            },
          ),
          const Divider(),
          ApiKeyTile(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => const ApiKeyDialog(),
              );
            },
          ),
          const Divider(),
          ExportDataTile(onTap: _exportData),
          const Divider(),
          ImportDataTile(onTap: _importData),
          const Divider(),
          AppInfoTile(
            onTap: () {
              // TODO: 앱 정보 표시
            },
          ),
        ],
      ),
    );
  }
}
