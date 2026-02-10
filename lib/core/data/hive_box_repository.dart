import 'package:hive/hive.dart';

abstract class HiveBoxRepository<T> {
  HiveBoxRepository(this.boxName);

  final String boxName;

  Box<T>? _box;
  Future<Box<T>>? _opening; // 동시 open 방지

  Future<Box<T>> get box async {
    // 이미 열려있으면 즉시 반환
    if (_box != null && _box!.isOpen) return _box!;

    // 이미 누군가 열고 있으면 그 Future 재사용
    if (_opening != null) return _opening!;

    // 새로 열기
    _opening = Hive.openBox<T>(boxName).then((b) {
      _box = b;
      return b;
    }).whenComplete(() {
      _opening = null;
    });

    return _opening!;
  }

  bool get isOpen => _box?.isOpen == true;
}