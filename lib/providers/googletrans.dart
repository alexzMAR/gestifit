import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String> translateToSpanish(String text, String apiKey) async {
  final response = await http.post(
    Uri.parse('https://translation.googleapis.com/language/translate/v2'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'q': text,
      'target': 'es',
      'format': 'text',
      'key': apiKey,
    }),
  );

  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    return jsonResponse['data']['translations'][0]['translatedText'];
  } else {
    throw Exception('Error en la traducción: ${response.body}');
  }
}
