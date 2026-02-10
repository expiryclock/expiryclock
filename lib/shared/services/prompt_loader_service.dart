import 'package:flutter/services.dart';

class PromptLoaderService {
  static final PromptLoaderService _instance = PromptLoaderService._internal();
  factory PromptLoaderService() => _instance;
  PromptLoaderService._internal();

  // 메모리에 로드된 프롬프트들
  String? _imageAnalysisPrompt;

  // 이미지 분석 프롬프트 getter
  String get imageAnalysisPrompt {
    if (_imageAnalysisPrompt == null) {
      throw StateError('프롬프트가 아직 로드되지 않았습니다. initialize()를 먼저 호출하세요.');
    }
    return _imageAnalysisPrompt!;
  }

  // 앱 시작 시 모든 프롬프트를 메모리에 로드
  Future<void> initialize() async {
    _imageAnalysisPrompt = await rootBundle.loadString(
      'assets/prompts/image_analysis_prompt.txt',
    );
  }
}
