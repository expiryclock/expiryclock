/// 마지막 촬영 정보를 담는 Value Object
class LastCapturedInfo {
  final String? imagePath;
  final String? itemId;

  const LastCapturedInfo({this.imagePath, this.itemId});

  /// 빈 상태의 LastCapturedInfo 생성
  const LastCapturedInfo.empty() : imagePath = null, itemId = null;

  /// 새로운 값으로 복사
  LastCapturedInfo copyWith({String? imagePath, String? itemId}) {
    return LastCapturedInfo(
      imagePath: imagePath ?? this.imagePath,
      itemId: itemId ?? this.itemId,
    );
  }

  /// 정보가 있는지 확인
  bool get hasInfo => imagePath != null && itemId != null;
}
