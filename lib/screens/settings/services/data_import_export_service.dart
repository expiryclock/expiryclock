// external
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

// internal
import 'package:expiryclock/core/models/expiry_item.dart';
import 'package:expiryclock/core/data/item_repository.dart';

/// 데이터 내보내기/가져오기 서비스
class DataImportExportService {
  DataImportExportService._();
  static final instance = DataImportExportService._();

  /// 아이템 데이터를 JSON으로 내보내기 (이미지 제외)
  Future<void> exportItems(ItemRepository repository) async {
    try {
      final items = repository.getAll();

      // 이미지 경로를 제외한 데이터만 추출
      final exportData = items.map((item) {
        return {
          'id': item.id,
          'name': item.name,
          'category': item.category,
          'expiryDateMillis': item.expiryDateMillis,
          'registeredAtMillis': item.registeredAtMillis,
          'notifyBeforeDays': item.notifyBeforeDays,
          'memo': item.memo,
          'quantity': item.quantity,
        };
      }).toList();

      final jsonData = {
        'version': '1.0',
        'exportedAt': DateTime.now().toIso8601String(),
        'itemCount': exportData.length,
        'items': exportData,
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(jsonData);

      // 임시 파일로 저장
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${directory.path}/expiry_items_$timestamp.json');
      await file.writeAsString(jsonString);

      // 파일 공유
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: '만료기한 아이템 내보내기',
        text: '총 ${exportData.length}개의 아이템이 내보내졌습니다.',
      );

      debugPrint('데이터 내보내기 완료: ${exportData.length}개 아이템');
    } catch (e) {
      debugPrint('데이터 내보내기 실패: $e');
      rethrow;
    }
  }

  /// JSON 파일에서 아이템 데이터 가져오기
  Future<ImportResult> importItems(ItemRepository repository, File file) async {
    try {
      final jsonString = await file.readAsString();
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

      // 버전 확인
      final version = jsonData['version'] as String?;
      if (version != '1.0') {
        throw Exception('지원하지 않는 파일 버전입니다: $version');
      }

      final items = jsonData['items'] as List<dynamic>;
      int importedCount = 0;
      int skippedCount = 0;
      int updatedCount = 0;

      for (final itemData in items) {
        final data = itemData as Map<String, dynamic>;

        // 기존 아이템 확인
        final id = data['id'] as String;
        final existingItem = repository.getById(id);

        // ExpiryItem 생성 (이미지는 빈 리스트)
        final item = ExpiryItem(
          id: id,
          images: [], // 이미지는 가져오지 않음
          name: data['name'] as String,
          category: data['category'] as String,
          expiryDateMillis: data['expiryDateMillis'] as int,
          registeredAtMillis: data['registeredAtMillis'] as int,
          notifyBeforeDays: data['notifyBeforeDays'] as int,
          memo: data['memo'] as String?,
          quantity: data['quantity'] as int? ?? 1,
        );

        if (existingItem != null) {
          // 기존 아이템이 있으면 건너뛰기 (나중에 옵션으로 덮어쓰기 가능하게 할 수 있음)
          skippedCount++;
        } else {
          // 새로운 아이템 추가
          await repository.upsert(item);
          importedCount++;
        }
      }

      debugPrint('데이터 가져오기 완료: 추가 $importedCount, 건너뜀 $skippedCount');

      return ImportResult(
        imported: importedCount,
        skipped: skippedCount,
        updated: updatedCount,
      );
    } catch (e) {
      debugPrint('데이터 가져오기 실패: $e');
      rethrow;
    }
  }

  /// JSON 파일에서 아이템 데이터 가져오기 (덮어쓰기 모드)
  Future<ImportResult> importItemsWithOverwrite(
    ItemRepository repository,
    File file,
  ) async {
    try {
      final jsonString = await file.readAsString();
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

      // 버전 확인
      final version = jsonData['version'] as String?;
      if (version != '1.0') {
        throw Exception('지원하지 않는 파일 버전입니다: $version');
      }

      final items = jsonData['items'] as List<dynamic>;
      int importedCount = 0;
      int updatedCount = 0;

      for (final itemData in items) {
        final data = itemData as Map<String, dynamic>;

        // 기존 아이템 확인
        final id = data['id'] as String;
        final existingItem = repository.getById(id);

        // ExpiryItem 생성
        final item = ExpiryItem(
          id: id,
          images: existingItem?.images ?? [], // 기존 이미지 유지, 없으면 빈 리스트
          name: data['name'] as String,
          category: data['category'] as String,
          expiryDateMillis: data['expiryDateMillis'] as int,
          registeredAtMillis: data['registeredAtMillis'] as int,
          notifyBeforeDays: data['notifyBeforeDays'] as int,
          memo: data['memo'] as String?,
          quantity: data['quantity'] as int? ?? 1,
        );

        if (existingItem != null) {
          updatedCount++;
        } else {
          importedCount++;
        }

        await repository.upsert(item);
      }

      debugPrint('데이터 가져오기 완료 (덮어쓰기): 추가 $importedCount, 업데이트 $updatedCount');

      return ImportResult(
        imported: importedCount,
        skipped: 0,
        updated: updatedCount,
      );
    } catch (e) {
      debugPrint('데이터 가져오기 실패: $e');
      rethrow;
    }
  }
}

/// 가져오기 결과
class ImportResult {
  const ImportResult({
    required this.imported,
    required this.skipped,
    required this.updated,
  });

  final int imported;
  final int skipped;
  final int updated;

  int get total => imported + skipped + updated;
}
