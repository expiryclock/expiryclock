// external
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// internal
import 'package:expiryclock/core/constants/ai_provider.dart';
import 'package:expiryclock/core/security/secure_storage_key_store.dart';

class ApiKeyDialog extends StatefulWidget {
  const ApiKeyDialog({super.key});

  @override
  State<ApiKeyDialog> createState() => _ApiKeyDialogState();
}

class _ApiKeyDialogState extends State<ApiKeyDialog> {
  final _openAiController = TextEditingController();
  final _openRouterController = TextEditingController();
  final _geminiController = TextEditingController();
  final _keyStore = SecureStorageKeyStore();

  bool _isLoading = true;
  bool _obscureOpenAi = true;
  bool _obscureOpenRouter = true;
  bool _obscureGemini = true;

  @override
  void initState() {
    super.initState();
    _loadKeys();
  }

  Future<void> _loadKeys() async {
    final openAiKey = await _keyStore.read(AiProvider.openai.keyName);
    final openRouterKey = await _keyStore.read(AiProvider.openrouter.keyName);
    final geminiKey = await _keyStore.read(AiProvider.google.keyName);

    setState(() {
      _openAiController.text = openAiKey ?? '';
      _openRouterController.text = openRouterKey ?? '';
      _geminiController.text = geminiKey ?? '';
      _isLoading = false;
    });
  }

  Future<void> _saveKeys() async {
    try {
      // 빈 문자열이 아닌 경우만 저장
      if (_openAiController.text.isNotEmpty) {
        await _keyStore.save(
          name: AiProvider.openai.keyName,
          value: _openAiController.text,
        );
      }
      if (_openRouterController.text.isNotEmpty) {
        await _keyStore.save(
          name: AiProvider.openrouter.keyName,
          value: _openRouterController.text,
        );
      }
      if (_geminiController.text.isNotEmpty) {
        await _keyStore.save(
          name: AiProvider.google.keyName,
          value: _geminiController.text,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('API 키가 저장되었습니다'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('저장 실패: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('URL을 열 수 없습니다'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildKeySection({
    required String title,
    required String url,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    required String hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            labelText: title,
            hintText: hintText,
            prefixIcon: const Icon(Icons.vpn_key),
            suffixIcon: IconButton(
              icon: Icon(obscureText ? Icons.visibility : Icons.visibility_off),
              onPressed: onToggleVisibility,
            ),
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: () => _launchUrl(url),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                const Icon(Icons.open_in_new, size: 14, color: Colors.blue),
                const SizedBox(width: 4),
                Text(
                  'API 키 발급받기',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue[700],
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _openAiController.dispose();
    _openRouterController.dispose();
    _geminiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const AlertDialog(
        content: SizedBox(
          height: 100,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return AlertDialog(
      title: const Text('AI API 키 관리'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // OpenAI API Key
            _buildKeySection(
              title: 'OpenAI API Key',
              url: 'https://platform.openai.com/api-keys',
              controller: _openAiController,
              obscureText: _obscureOpenAi,
              onToggleVisibility: () {
                setState(() {
                  _obscureOpenAi = !_obscureOpenAi;
                });
              },
              hintText: 'sk-...',
            ),
            const SizedBox(height: 16),

            // OpenRouter API Key
            _buildKeySection(
              title: 'OpenRouter API Key',
              url: 'https://openrouter.ai/keys',
              controller: _openRouterController,
              obscureText: _obscureOpenRouter,
              onToggleVisibility: () {
                setState(() {
                  _obscureOpenRouter = !_obscureOpenRouter;
                });
              },
              hintText: 'sk-or-v1-...',
            ),
            const SizedBox(height: 16),

            // Gemini API Key
            _buildKeySection(
              title: 'Gemini API Key',
              url: 'https://aistudio.google.com/app/apikey',
              controller: _geminiController,
              obscureText: _obscureGemini,
              onToggleVisibility: () {
                setState(() {
                  _obscureGemini = !_obscureGemini;
                });
              },
              hintText: 'AI...',
            ),
            const SizedBox(height: 8),
            const Text(
              '※ 최소 하나 이상의 API 키를 입력해주세요',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        ElevatedButton(onPressed: _saveKeys, child: const Text('저장')),
      ],
    );
  }
}
