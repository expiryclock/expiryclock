import 'dart:io';
import 'package:flutter/material.dart';

class BottomButtonsSection extends StatelessWidget {
  const BottomButtonsSection({
    super.key,
    required this.onShoot,
    required this.onPickFromGallery,
    required this.onNavigateToList,
    this.lastCapturedImagePath,
  });

  final VoidCallback onShoot;
  final VoidCallback onPickFromGallery;
  final VoidCallback onNavigateToList;
  final String? lastCapturedImagePath;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 3,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Align(
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildGalleryButton(),
                _buildShootButton(),
                _buildListButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 갤러리 버튼 (마지막 촬영 이미지 또는 갤러리 아이콘)
  Widget _buildGalleryButton() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onPickFromGallery,
          child: lastCapturedImagePath != null
              ? Container(
                  width: 60,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.file(
                      File(lastCapturedImagePath!),
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              : const Icon(Icons.photo_library_outlined, size: 32),
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  /// 촬영 버튼
  Widget _buildShootButton() {
    return GestureDetector(
      onTap: onShoot,
      child: SizedBox(
        width: 100,
        height: 100,
        child: Image.asset(
          'assets/images/camera_shoot_button.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  /// 리스트 버튼
  Widget _buildListButton() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onNavigateToList,
          icon: const Icon(Icons.library_add_outlined),
          iconSize: 28,
        ),
        const Text('리스트', style: TextStyle(fontSize: 10)),
      ],
    );
  }
}
