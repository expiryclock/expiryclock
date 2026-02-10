import 'dart:convert';
import 'package:expiryclock/shared/utils/date_parser_util.dart';

class ImageAnalysisResult {
  final String item;
  final String category;
  final String expiryDate;

  ImageAnalysisResult({
    required this.item,
    required this.category,
    required this.expiryDate,
  });

  factory ImageAnalysisResult.fromJson(Map<String, dynamic> json) {
    return ImageAnalysisResult(
      item: json['item'] as String? ?? '',
      category: json['category'] as String? ?? '',
      expiryDate: json['expiryDate'] as String? ?? '',
    );
  }

  factory ImageAnalysisResult.fromJsonString(String jsonString) {
    try {
      // 마크다운 코드 블록 제거 (```json ... ``` 또는 ``` ... ```)
      String cleanedString = jsonString
          .replaceAll(RegExp(r'```json\s*'), '')
          .replaceAll(RegExp(r'```\s*'), '')
          .trim();
      
      final json = jsonDecode(cleanedString) as Map<String, dynamic>;
      return ImageAnalysisResult.fromJson(json);
    } catch (e) {
      // JSON 파싱 실패 시 빈 결과 반환
      return ImageAnalysisResult(
        item: '',
        category: '',
        expiryDate: '',
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'item': item,
      'category': category,
      'expiryDate': expiryDate,
    };
  }

  bool get isEmpty => item.isEmpty && category.isEmpty && expiryDate.isEmpty;

  /// expiryDate 문자열을 DateTime으로 파싱
  /// DateParserUtil을 사용하여 다양한 날짜 형식 지원
  DateTime? parseExpiryDate() {
    return DateParserUtil.parseDate(expiryDate);
  }
}
