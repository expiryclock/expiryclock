/// 아이템 정렬 옵션
enum SortOption {
  /// 만료일 빠른 순 (D-Day 오름차순)
  expiryDateAsc,

  /// 만료일 늦은 순 (D-Day 내림차순)
  expiryDateDesc,

  /// 이름 오름차순 (가나다순)
  nameAsc,

  /// 이름 내림차순 (가나다 역순)
  nameDesc,

  /// 등록일 최신순
  registeredDateDesc,

  /// 등록일 오래된순
  registeredDateAsc;

  /// 정렬 옵션의 표시 이름
  String get displayName {
    switch (this) {
      case SortOption.expiryDateAsc:
        return '만료일 빠른 순';
      case SortOption.expiryDateDesc:
        return '만료일 늦은 순';
      case SortOption.nameAsc:
        return '이름 오름차순';
      case SortOption.nameDesc:
        return '이름 내림차순';
      case SortOption.registeredDateDesc:
        return '등록일 최신순';
      case SortOption.registeredDateAsc:
        return '등록일 오래된순';
    }
  }
}
