import 'package:hive/hive.dart';

part 'expiry_item.g.dart';

@HiveType(typeId: 0)
class ExpiryItem {
  ExpiryItem({
    required this.id,
    required this.images,
    required this.name,
    required this.category,
    required this.expiryDateMillis,
    required this.registeredAtMillis,
    required this.notifyBeforeDays,
    required this.memo,
    this.quantity = 1,
  });

  // DateTime을 받는 편의 생성자
  ExpiryItem.fromDateTime({
    required String id,
    required List<String> images,
    required String name,
    required String category,
    required DateTime expiryDate,
    required DateTime registeredAt,
    required int notifyBeforeDays,
    required String? memo,
    int quantity = 1,
  }) : this(
         id: id,
         images: images,
         name: name,
         category: category,
         expiryDateMillis: expiryDate.millisecondsSinceEpoch,
         registeredAtMillis: registeredAt.millisecondsSinceEpoch,
         notifyBeforeDays: notifyBeforeDays,
         memo: memo,
         quantity: quantity,
       );

  @HiveField(0)
  final String id;

  @HiveField(1)
  final List<String> images;

  @HiveField(2)
  String name;

  @HiveField(3)
  String category;

  @HiveField(4)
  final int expiryDateMillis;

  @HiveField(5)
  final int registeredAtMillis;

  @HiveField(6)
  String? memo;

  @HiveField(7)
  int quantity;

  @HiveField(8)
  int notifyBeforeDays;

  DateTime get expiryDate =>
      DateTime.fromMillisecondsSinceEpoch(expiryDateMillis);

  DateTime get registeredAt =>
      DateTime.fromMillisecondsSinceEpoch(registeredAtMillis);

  int get dDay {
    final now = DateTime.now();
    final onlyDateNow = DateTime(now.year, now.month, now.day);
    final onlyDateExp = DateTime(
      expiryDate.year,
      expiryDate.month,
      expiryDate.day,
    );
    return onlyDateExp.difference(onlyDateNow).inDays;
  }
}

// TODO: extensions로 빼기
String formatDate(DateTime dt) =>
    '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
