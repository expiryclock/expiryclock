// external
import 'package:logger/logger.dart';

// internal
import 'package:expiryclock/core/constants/ai_provider.dart';
import 'package:expiryclock/shared/ai/clients/openai.dart';
import 'package:expiryclock/shared/ai/clients/openrouter.dart';
import 'package:expiryclock/shared/ai/clients/google.dart';
import 'package:expiryclock/shared/models/image_analysis_result.dart';
import 'prompt_loader_service.dart';

final logger = Logger();

class ImageAnalysisService {
  // 이미지 분석
  Future<ImageAnalysisResult?> analysis(String imagePath) async {
    String? result;

    // Image를 포함하여 분석할 수 있는 LLM API를 호출
    result = await _callLlmApiWithImage(imagePath);
    logger.d(result);

    if (result == null) {
      return null;
    }

    // JSON 문자열을 파싱하여 ImageAnalysisResult 객체로 변환
    try {
      return ImageAnalysisResult.fromJsonString(result);
    } catch (e) {
      logger.e('이미지 분석 결과 파싱 오류: $e');
      return null;
    }
  }

  Future<String?> _callLlmApiWithImage(String imagePath) async {
    String? result;

    // 우선순위: OpenRouter -> Gemini -> OpenAI
    if (OpenRouter.instance.hasApiKey()) {
      result = await _callApiWithImage(AiProvider.openrouter, imagePath);
      if (result != null) return result;
      return null; // API 키가 있지만 결과가 없으면 여기서 종료
    }

    if (Gemini.instance.hasApiKey()) {
      result = await _callApiWithImage(AiProvider.google, imagePath);
      if (result != null) return result;
      return null; // API 키가 있지만 결과가 없으면 여기서 종료
    }

    if (OpenAI.instance.hasApiKey()) {
      result = await _callApiWithImage(AiProvider.openai, imagePath);
      if (result != null) return result;
      return null; // API 키가 있지만 결과가 없으면 여기서 종료
    }

    return null; // 어떤 API 키도 없는 경우
  }

  // 통합 API 호출 함수
  Future<String?> _callApiWithImage(
    AiProvider provider,
    String imagePath,
  ) async {
    try {
      final prompt = PromptLoaderService().imageAnalysisPrompt;

      switch (provider) {
        case AiProvider.openai:
          return await OpenAI.instance.requestCompletionWithImage(
            prompt: prompt,
            imagePath: imagePath,
          );
        case AiProvider.openrouter:
          return await OpenRouter.instance.requestCompletionWithImage(
            prompt: prompt,
            imagePath: imagePath,
          );
        case AiProvider.google:
          return await Gemini.instance.requestCompletionWithImage(
            prompt: prompt,
            imagePath: imagePath,
          );
      }
    } catch (e) {
      logger.e('${provider.id} 이미지 분석 오류: $e');
      return null;
    }
  }
}
