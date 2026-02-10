enum AiProvider {
  openrouter(
    id: 'openrouter',
    keyName: 'openrouter_api_key',
    baseUrl: 'https://openrouter.ai/api/v1',
  ),
  openai(
    id: 'openai',
    keyName: 'openai_api_key',
    baseUrl: 'https://api.openai.com/v1',
  ),
  google(
    id: 'google',
    keyName: 'google_ai_api_key',
    baseUrl: 'https://generativelanguage.googleapis.com/v1beta',
  );

  final String id;
  final String keyName;
  final String baseUrl;

  const AiProvider({
    required this.id,
    required this.keyName,
    required this.baseUrl,
  });

  /// 문자열을 enum으로 역변환 (저장값 복원용)
  static AiProvider fromId(String id) {
    return AiProvider.values.firstWhere((e) => e.id == id);
  }
}
