import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;

import '../../../core/security/key_store.dart';
import '../../../core/security/secure_storage_key_store.dart';

final logger = Logger();

/// OpenAI API 클라이언트
/// OpenAI의 GPT-4 Vision 모델을 사용하여 텍스트 및 이미지 분석을 수행합니다.
class OpenAI {
  static const String _baseUrl = 'https://api.openai.com/v1';
  static const String _model = 'gpt-4-vision-preview';
  static const String _keyName = 'openai_api_key';

  // 싱글톤 인스턴스
  static OpenAI? _instance;
  static OpenAI get instance {
    _instance ??= OpenAI._internal();
    return _instance!;
  }

  // DI
  final KeyStore _keyStore;
  final http.Client _http;

  // 사용자가 저장한 key를 가져오기 위함
  String? _apiKey;
  StreamSubscription<KeyChange>? _keySub;

  // private 생성자 (테스트 시 DI 지원)
  OpenAI._internal({KeyStore? keyStore, http.Client? httpClient})
    : _keyStore = keyStore ?? SecureStorageKeyStore(),
      _http = httpClient ?? http.Client();

  /// 앱 시작 시 호출하여 API 키를 미리 캐시에 로드
  static Future<void> initialize() async {
    await instance._init();
  }

  // 생성자에서 초기화 (비동기 함수 호출은 불가하므로, 별도 init 메서드 사용)
  Future<void> _init() async {
    try {
      _apiKey = await _keyStore.read(_keyName);

      // 키 변경 실시간 감지
      _keySub = _keyStore.changes.listen((event) async {
        if (event.name != _keyName) return;
        if (event.name == _keyName) {
          if (event.type == KeyChangeType.deleted) {
            _apiKey = null;
            logger.i('OpenAI API key deleted');
          } else {
            _apiKey = await _keyStore.read(_keyName);
            logger.i('OpenAI API key updated');
          }
        }
      });
    } catch (e, st) {
      logger.w('Failed to prime OpenAI key', error: e, stackTrace: st);
    }
  }

  // _apiKey가 없을 경우, _keyStore에 접근하여 키 가져 오도록 함.
  Future<String> _getApiKey() async {
    _apiKey ??= await _keyStore.read(_keyName);
    final key = _apiKey;
    if (key == null || key.isEmpty) {
      throw StateError('OpenAI API 키가 설정되어 있지 않습니다.');
    }
    return key;
    // 참고: 필요 시 여기서 키 포맷/검증 로직 추가 가능
  }

  /// OpenAI API 키가 설정되어 있는지 확인
  bool hasApiKey() {
    return _apiKey != null && _apiKey!.isNotEmpty;
  }

  Future<void> dispose() async {
    await _keySub?.cancel();
    _http.close();
  }

  /// OpenAI GPT-4 Vision API를 사용하여 텍스트와 함께 이미지 분석을 수행합니다.
  ///
  /// [prompt]는 이미지와 함께 전달할 텍스트 프롬프트입니다.
  /// [imagePath]는 분석할 이미지의 로컬 파일 경로입니다.
  ///
  /// 반환값은 OpenAI API 응답의 텍스트 내용입니다.
  Future<String> requestCompletionWithImage({
    required String prompt,
    required String imagePath,
  }) async {
    try {
      final apiKey = await _getApiKey();

      final imageFile = File(imagePath);
      if (!await imageFile.exists()) {
        return '이미지 파일을 찾을 수 없습니다.';
      }

      // 이미지를 base64로 인코딩
      final List<int> imageBytes = await imageFile.readAsBytes();
      final String base64Image = base64Encode(imageBytes);

      // API 요청 URL
      final url = Uri.parse('$_baseUrl/chat/completions');

      // 요청 본문 구성
      final Map<String, dynamic> requestBody = {
        'model': _model,
        'messages': [
          {
            'role': 'user',
            'content': [
              {'type': 'text', 'text': prompt},
              {
                'type': 'image_url',
                'image_url': {'url': 'data:image/jpeg;base64,$base64Image'},
              },
            ],
          },
        ],
        'max_tokens': 1000,
      };

      // API 요청 보내기
      final response = await _http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['choices'][0]['message']['content'] ??
            '응답에서 텍스트를 찾을 수 없습니다.';
      } else {
        return '오류: ${response.statusCode} - ${response.body}';
      }
    } catch (e) {
      return '이미지 분석 중 오류가 발생했습니다: $e';
    }
  }
}
