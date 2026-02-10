import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';

/// 이미지를 프리뷰 영역에 맞게 크롭하는 서비스
class ImageCropService {
  ImageCropService._();
  static final ImageCropService instance = ImageCropService._();

  /// 카메라 프리뷰에 보이는 영역만큼 이미지를 크롭
  /// 
  /// [imagePath]: 원본 이미지 경로
  /// [previewSize]: 카메라 프리뷰의 실제 해상도 (width x height)
  /// [displaySize]: 화면에 표시되는 프리뷰 영역 크기
  /// [isPortrait]: 세로 모드 여부
  Future<String> cropToPreviewSize({
    required String imagePath,
    required Size previewSize,
    required Size displaySize,
    required bool isPortrait,
  }) async {
    try {
      // 원본 이미지 로드
      final bytes = await File(imagePath).readAsBytes();
      final originalImage = img.decodeImage(bytes);
      
      if (originalImage == null) {
        throw Exception('이미지를 디코딩할 수 없습니다');
      }

      // 카메라 이미지는 회전되어 있을 수 있으므로 방향 보정
      // portrait 모드에서는 previewSize의 width/height가 바뀌어 있음
      final imageWidth = originalImage.width;
      final imageHeight = originalImage.height;

      // 프리뷰의 현재 방향 기준 가로/세로 비율
      final previewAspect = isPortrait
          ? (previewSize.height / previewSize.width)
          : (previewSize.width / previewSize.height);

      // 디스플레이 영역의 가로/세로 비율
      final displayAspect = displaySize.width / displaySize.height;

      // 크롭할 영역 계산
      int cropWidth, cropHeight, cropX, cropY;

      if (previewAspect > displayAspect) {
        // 프리뷰가 더 세로로 길 때 - 좌우를 크롭
        cropHeight = imageHeight;
        cropWidth = (imageHeight / displayAspect).round();
        cropX = ((imageWidth - cropWidth) / 2).round();
        cropY = 0;
      } else {
        // 프리뷰가 더 가로로 길 때 - 상하를 크롭
        cropWidth = imageWidth;
        cropHeight = (imageWidth * displayAspect).round();
        cropX = 0;
        cropY = ((imageHeight - cropHeight) / 2).round();
      }

      // 크롭 영역이 이미지 범위를 벗어나지 않도록 보정
      cropX = cropX.clamp(0, imageWidth - 1);
      cropY = cropY.clamp(0, imageHeight - 1);
      cropWidth = cropWidth.clamp(1, imageWidth - cropX);
      cropHeight = cropHeight.clamp(1, imageHeight - cropY);

      // 이미지 크롭
      final croppedImage = img.copyCrop(
        originalImage,
        x: cropX,
        y: cropY,
        width: cropWidth,
        height: cropHeight,
      );

      // 크롭된 이미지를 원본 파일에 덮어쓰기
      final croppedBytes = img.encodeJpg(croppedImage, quality: 95);
      await File(imagePath).writeAsBytes(croppedBytes);

      return imagePath;
    } catch (e) {
      debugPrint('이미지 크롭 실패: $e');
      // 크롭 실패 시 원본 이미지 경로 반환
      return imagePath;
    }
  }
}
