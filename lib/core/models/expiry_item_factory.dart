import 'package:expiryclock/core/models/expiry_item.dart';

class ExpiryItemFactory {
  static ExpiryItem createTemporary({
    required String id,
    required String imagePath,
    required DateTime now,
  }) {
    return ExpiryItem.fromDateTime(
      id: id,
      images: [imagePath],
      name: '분석 중...',
      category: '기타',
      expiryDate: now.add(const Duration(days: 7)),
      registeredAt: now,
      notifyBeforeDays: 2,
      memo: '',
    );
  }
}
