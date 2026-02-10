import 'package:intl/intl.dart';

/// 날짜 파싱 유틸리티 클래스
class DateParserUtil {
  DateParserUtil._();

  /// 문자열을 DateTime으로 파싱
  /// 다양한 형식을 지원 (YYYY.MM.DD, YYYY-MM-DD, YYYY/MM/DD, YYYYMMDD 등)
  /// intl 패키지의 DateFormat을 활용하여 다양한 날짜 형식 처리
  static DateTime? parseDate(String dateString) {
    if (dateString.isEmpty) return null;

    // 지원하는 날짜 형식 리스트
    final formats = [
      'yyyy.MM.dd',
      'yyyy-MM-dd',
      'yyyy/MM/dd',
      'yyyyMMdd',
      'yy.MM.dd',
      'yy-MM-dd',
      'yy/MM/dd',
      'yyMMdd',
      'yyyy.M.d',
      'yyyy-M-d',
      'yyyy/M/d',
      'yy.M.d',
      'yy-M-d',
      'yy/M/d',
    ];

    // 각 형식으로 파싱 시도
    for (final formatStr in formats) {
      try {
        final format = DateFormat(formatStr);
        final parsedDate = format.parseStrict(dateString);
        
        // yy 형식(2자리 연도)인 경우 2000년대로 조정
        if (formatStr.startsWith('yy') && parsedDate.year < 100) {
          return DateTime(2000 + parsedDate.year, parsedDate.month, parsedDate.day);
        }
        
        return parsedDate;
      } catch (e) {
        // 현재 형식으로 파싱 실패 시 다음 형식 시도
        continue;
      }
    }

    // 모든 형식으로 파싱 실패 시 null 반환
    return null;
  }
}
