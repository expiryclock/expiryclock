// external
import 'package:flutter/material.dart';
import 'dart:io';

// internal
import 'package:expiryclock/core/models/expiry_item.dart';

/// 아이템 이미지 미리보기 위젯
class ItemImagePreview extends StatelessWidget {
  const ItemImagePreview({super.key, required this.item, required this.onTap});

  final ExpiryItem? item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (item?.images.isNotEmpty == true) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          height: 220,
          decoration: BoxDecoration(
            color: Colors.black12,
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.file(
                File(item!.images.first),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Center(child: Text('이미지 로드 실패')),
              ),
              const Positioned(
                top: 8,
                right: 8,
                child: Icon(
                  Icons.zoom_in,
                  color: Colors.white,
                  size: 32,
                  shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Container(
        height: 140,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text('미리보기 이미지 없음'),
      );
    }
  }
}

/// 전체 화면 이미지 뷰
class FullScreenImageView extends StatelessWidget {
  const FullScreenImageView({super.key, required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Container(color: Colors.black),
            _buildCenterImage(context),
            _buildBackButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterImage(BuildContext context) {
    return Center(
      child: AspectRatio(
        aspectRatio:
            MediaQuery.of(context).size.width /
            (MediaQuery.of(context).size.height * 0.7),
        child: InteractiveViewer(
          child: Image.file(
            File(imagePath),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (_, __, ___) => const Center(
              child: Text('이미지 로드 실패', style: TextStyle(color: Colors.white)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Positioned(
      top: 16,
      left: 16,
      child: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }
}
