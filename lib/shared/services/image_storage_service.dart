import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// 이미지를 앱 전용 폴더에 저장하고 관리하는 서비스
class ImageStorageService {
  ImageStorageService._();
  static final ImageStorageService instance = ImageStorageService._();

  /// 이미지를 앱 전용 폴더에 저장하고 저장된 경로를 반환
  Future<String> saveImage(String sourcePath, {String? fileName}) async {
    final appDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory(path.join(appDir.path, 'images'));

    // images 폴더가 없으면 생성
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    // 고유한 파일명 생성
    final extension = path.extension(sourcePath);

    // 파일명 결정
    final resolvedFileName = fileName?.isNotEmpty == true
        ? (path.extension(fileName!) == '' ? '$fileName$extension' : fileName)
        : '${DateTime.now().millisecondsSinceEpoch}$extension';

    final targetPath = path.join(imagesDir.path, resolvedFileName);

    // 파일 복사
    final sourceFile = File(sourcePath);
    await sourceFile.copy(targetPath);

    return targetPath;
  }

  /// 여러 이미지를 한 번에 저장
  Future<List<String>> saveImages(List<String> sourcePaths) async {
    final savedPaths = <String>[];
    for (final sourcePath in sourcePaths) {
      final savedPath = await saveImage(sourcePath);
      savedPaths.add(savedPath);
    }
    return savedPaths;
  }

  /// 저장된 이미지 파일 삭제
  Future<void> deleteImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // 파일 삭제 실패 시 무시 (이미 삭제되었거나 권한 문제 등)
    }
  }

  /// 여러 이미지 파일 삭제
  Future<void> deleteImages(List<String> imagePaths) async {
    for (final imagePath in imagePaths) {
      await deleteImage(imagePath);
    }
  }

  /// 이미지 파일이 존재하는지 확인
  Future<bool> imageExists(String imagePath) async {
    final file = File(imagePath);
    return await file.exists();
  }
}
