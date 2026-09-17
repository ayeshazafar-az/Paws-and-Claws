import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  final envFile = File('.env');
  if (!envFile.existsSync()) return;
  final lines = await envFile.readAsLines();
  String? apiKey;
  for (var line in lines) {
    if (line.startsWith('GEMINI_API_KEY=')) {
      apiKey = line
          .split('=')[1]
          .trim()
          .replaceAll('"', '')
          .replaceAll("'", "");
    }
  }

  if (apiKey == null || apiKey.isEmpty) return;

  final url = Uri.parse(
    'https://generativelanguage.googleapis.com/v1beta/models?key=' + apiKey,
  );
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final models = data['models'] as List<dynamic>;
    for (var m in models) {
      final name = m['name'];
      final supported = m['supportedGenerationMethods'] as List<dynamic>?;
      if (supported != null && supported.contains('generateContent')) {
        print(name + ' (Supports generateContent)');
      }
    }
  } else {
    print('Failed: ' + response.body);
  }
}
