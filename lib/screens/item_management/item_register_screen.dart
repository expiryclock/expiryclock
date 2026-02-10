import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/expiry_item.dart';
import '../../core/data/item_repository.dart';
import '../camera/services/camera_shoot_service.dart';

class CaptureReviewScreen extends ConsumerStatefulWidget {
  const CaptureReviewScreen({super.key, required this.imagePath});
  final String imagePath;

  @override
  ConsumerState<CaptureReviewScreen> createState() =>
      _CaptureReviewScreenState();
}

class _CaptureReviewScreenState extends ConsumerState<CaptureReviewScreen> {
  Future<void> _regist() async {
    final now = DateTime.now();
    final itemId = now.millisecondsSinceEpoch.toString();

    // 1단계: 임시 아이템을 먼저 등록 (기본값 사용)
    final tempItem = ExpiryItem.fromDateTime(
      id: itemId,
      images: [widget.imagePath],
      name: '분석 중...', // 임시 이름
      category: '기타', // 임시 카테고리
      expiryDate: now.add(const Duration(days: 7)), // 기본 만료기한
      registeredAt: now,
      notifyBeforeDays: 2,
      memo: "",
    );

    final repository = ref.read(itemRepositoryProvider);

    // Hive DB에 임시 아이템 저장
    await repository.upsert(tempItem);

    if (!mounted) return;

    // 바로 list 화면으로 전환
    Navigator.of(context).pushNamed('/list', arguments: tempItem);

    // 2단계: 백그라운드에서 이미지 분석 및 업데이트
    CameraShootService(
      repository,
    ).analyzeAndUpdateItem(itemId, widget.imagePath, now);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('아이템 등록')),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(widget.imagePath),
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '이미지를 불러올 수 없습니다\n${widget.imagePath}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _regist,
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text('등록하기'),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
