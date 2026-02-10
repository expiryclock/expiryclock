// external
import 'package:flutter/material.dart';

// internal
import 'package:expiryclock/core/constants/start_screen.dart';

class StartScreenDialog extends StatefulWidget {
  const StartScreenDialog({super.key, required this.currentScreen});

  final StartScreen currentScreen;

  @override
  State<StartScreenDialog> createState() => _StartScreenDialogState();
}

class _StartScreenDialogState extends State<StartScreenDialog> {
  late StartScreen _selectedScreen;

  @override
  void initState() {
    super.initState();
    _selectedScreen = widget.currentScreen;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('시작 화면 선택'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('카메라 화면'),
            subtitle: const Text('앱 실행 시 바로 촬영 가능'),
            leading: Radio<StartScreen>(
              value: StartScreen.camera,
              groupValue: _selectedScreen,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedScreen = value;
                  });
                }
              },
            ),
            onTap: () {
              setState(() {
                _selectedScreen = StartScreen.camera;
              });
            },
          ),
          ListTile(
            title: const Text('아이템 리스트'),
            subtitle: const Text('등록된 아이템 목록 확인'),
            leading: Radio<StartScreen>(
              value: StartScreen.itemList,
              groupValue: _selectedScreen,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedScreen = value;
                  });
                }
              },
            ),
            onTap: () {
              setState(() {
                _selectedScreen = StartScreen.itemList;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_selectedScreen),
          child: const Text('확인'),
        ),
      ],
    );
  }
}
