// external
import 'package:expiryclock/core/models/expiry_item_factory.dart';
import 'package:flutter/material.dart';
import 'package:ulid/ulid.dart';

// internal
import 'package:expiryclock/core/constants/analysis_defaults.dart';
import 'package:expiryclock/core/data/item_repository.dart';
import 'package:expiryclock/core/models/expiry_item.dart';
import 'package:expiryclock/shared/services/image_storage_service.dart';
import 'package:expiryclock/shared/services/image_analysis_service.dart';

/// 촬영된 이미지 처리 결과
class CaptureResult {
  final String itemId;
  final String imagePath;

  const CaptureResult({required this.itemId, required this.imagePath});
}

/// 카메라 촬영 비즈니스 로직을 담당하는 서비스
class CameraShootService {
  final ItemRepository _repository;

  CameraShootService(this._repository);

  /// 촬영된 이미지를 처리하고 임시 아이템을 생성합니다.
  ///
  /// [capturedImagePath] 카메라로 촬영한 임시 이미지 경로
  ///
  /// 반환값: [CaptureResult] 생성된 아이템 ID와 저장된 이미지 경로
  Future<CaptureResult> processCapture(String capturedImagePath) async {
    // 사진 촬영 즉시 해당 아이템 고유 아이디 생성
    final itemId = Ulid().toString();
    final now = DateTime.now();

    // 임시 이미지를 앱에서 관리하는 영구 저장소에 별도 저장
    final savedImagePath = await ImageStorageService.instance.saveImage(
      capturedImagePath,
      fileName: itemId,
    );

    // 임시 아이템 생성 (기본값으로 사용)
    final tempItem = ExpiryItemFactory.createTemporary(
      id: itemId,
      imagePath: savedImagePath,
      now: now,
    );

    // Hive DB에 임시 아이템 저장
    await _repository.upsert(tempItem);

    // 백그라운드에서 LLM API 호출 및 업데이트 (비동기, 결과 대기 안 함)
    analyzeAndUpdateItem(itemId, savedImagePath, now);

    return CaptureResult(itemId: itemId, imagePath: savedImagePath);
  }

  // 백그라운드에서 이미지 분석 후 아이템 업데이트
  Future<void> analyzeAndUpdateItem(
    String itemId,
    String imagePath,
    DateTime registeredAt,
  ) async {
    try {
      // 이미지 분석
      final analysisResult = await ImageAnalysisService().analysis(imagePath);

      // 분석 결과에서 정보 추출
      String itemName = AnalysisDefaults.defaultItemName;
      String itemCategory = AnalysisDefaults.defaultItemCategory;
      DateTime itemExpiryDate = registeredAt.add(
        const Duration(days: AnalysisDefaults.defaultExpiryDays),
      );

      if (analysisResult != null && !analysisResult.isEmpty) {
        itemName = analysisResult.item;
        itemCategory = analysisResult.category;

        // 만료기한 파싱 시도
        final parsedDate = analysisResult.parseExpiryDate();
        if (parsedDate != null) {
          itemExpiryDate = parsedDate;
        }
      }

      // DB에서 동일한 아이템 검색 (name, category, expiryDate가 모두 일치)
      final existingItems = _repository.getAll();
      ExpiryItem? duplicateItem;

      for (final item in existingItems) {
        if (item.name == itemName &&
            item.category == itemCategory &&
            item.expiryDateMillis == itemExpiryDate.millisecondsSinceEpoch) {
          duplicateItem = item;
          break;
        }
      }

      if (duplicateItem != null) {
        // 중복 아이템이 존재하면 수량만 1 증가
        final updatedItem = ExpiryItem.fromDateTime(
          id: duplicateItem.id,
          images: duplicateItem.images,
          name: duplicateItem.name,
          category: duplicateItem.category,
          expiryDate: duplicateItem.expiryDate,
          registeredAt: duplicateItem.registeredAt,
          notifyBeforeDays: duplicateItem.notifyBeforeDays,
          memo: duplicateItem.memo,
          quantity: duplicateItem.quantity + 1,
        );

        await _repository.upsert(updatedItem);
        debugPrint(
          '기존 아이템 수량 증가: $itemName (${duplicateItem.quantity} -> ${duplicateItem.quantity + 1})',
        );

        // 새로 등록한 임시 아이템은 삭제 (이미지도 함께)
        await _repository.remove(itemId);
      } else {
        // 중복이 없으면 분석 결과로 아이템 업데이트
        final updatedItem = ExpiryItem.fromDateTime(
          id: itemId,
          images: [imagePath],
          name: itemName,
          category: itemCategory,
          expiryDate: itemExpiryDate,
          registeredAt: registeredAt,
          notifyBeforeDays: 2,
          memo: "",
        );

        await _repository.upsert(updatedItem);
        debugPrint('아이템 분석 완료: $itemName ($itemCategory)');
      }
    } catch (e) {
      debugPrint('이미지 분석 실패: $e');
      // 분석 실패 시에도 기본값으로 아이템은 유지됨
    }
  }
}
