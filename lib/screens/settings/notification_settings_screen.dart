import 'dart:async';
import 'package:expiryclock/core/models/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expiryclock/core/data/notification_settings_repository.dart';
import 'package:expiryclock/core/data/item_repository.dart';
import 'package:expiryclock/screens/settings/services/notification_service.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  final _repository = NotificationSettingsRepository();
  NotificationSettings? _settings;
  bool _isLoading = true;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await _repository.getSettings();
      setState(() {
        _settings = settings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('설정을 불러오는데 실패했습니다: $e')));
      }
    }
  }

  Future<void> _updateSettings(
    NotificationSettings newSettings, {
    bool showSnackBar = true,
  }) async {
    try {
      await _repository.saveSettings(newSettings);
      setState(() {
        _settings = newSettings;
      });

      // 모든 아이템의 알림을 새로운 설정으로 재스케줄링
      await _rescheduleAllNotifications(newSettings);

      if (mounted && showSnackBar) {
        // 기존 SnackBar를 제거하고 새로 표시
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('설정이 저장되었습니다'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('설정 저장에 실패했습니다: $e')));
      }
    }
  }

  /// 모든 아이템의 알림을 재스케줄링
  Future<void> _rescheduleAllNotifications(
    NotificationSettings settings,
  ) async {
    try {
      // 모든 아이템 가져오기
      final items = ref.read(itemRepositoryProvider).getAll();

      // 알림 재스케줄링
      await NotificationService.rescheduleAll(
        items: items,
        notificationHour: settings.notificationHour,
        notificationMinute: settings.notificationMinute,
        isEnabled: settings.isEnabled,
      );
    } catch (e) {
      // 에러가 발생해도 설정은 저장되었으므로 조용히 처리
      debugPrint('알림 재스케줄링 실패: $e');
    }
  }

  Future<void> _selectTime() async {
    if (_settings == null) return;

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: _settings!.notificationHour,
        minute: _settings!.notificationMinute,
      ),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final newSettings = _settings!.copyWith(
        notificationHour: picked.hour,
        notificationMinute: picked.minute,
      );
      await _updateSettings(newSettings);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('알림'),
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.grey.withValues(alpha: 0.5),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _settings == null
          ? const Center(child: Text('설정을 불러올 수 없습니다'))
          : ListView(
              children: [
                _buildNotificationToggle(),
                const Divider(),
                _buildNotificationTimeSection(),
                const Divider(),
                _buildInfoSection(),
              ],
            ),
    );
  }

  /// 알림 활성화/비활성화 토글
  Widget _buildNotificationToggle() {
    return SwitchListTile(
      title: const Text('알림 사용'),
      subtitle: const Text('만료기한 알림을 받습니다'),
      value: _settings!.isEnabled,
      onChanged: (value) {
        final newSettings = _settings!.copyWith(isEnabled: value);
        _updateSettings(newSettings);
      },
    );
  }

  /// 알림 시간 설정 섹션
  Widget _buildNotificationTimeSection() {
    return ListTile(
      leading: const Icon(Icons.access_time),
      title: const Text('알림 시간'),
      subtitle: Text(_settings!.formattedTime),
      trailing: const Icon(Icons.chevron_right),
      enabled: _settings!.isEnabled,
      onTap: _settings!.isEnabled ? _selectTime : null,
    );
  }

  /// 알림 설정 안내 섹션
  Widget _buildInfoSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '알림 설정 안내',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '• 처음 아이템을 등록할 때의 만료기한 전 알림 일 기본값을 설정하는 기능 입니다.\n'
            '• 현재 등록되어있는 모든 아이템의 만료기한 전 알림 일이 바뀌는 설정이 아닙니다.\n'
            '• 알림은 설정한 시간에 발송됩니다.\n'
            '• 이미 지난 만료기한에 대해서는 알림이 발송되지 않습니다.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _repository.close();
    super.dispose();
  }
}
