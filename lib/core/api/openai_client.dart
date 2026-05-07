import 'package:dio/dio.dart';
import '../models/audio_segment.dart';
import 'dart:convert';

class OpenAIClient {
  final String apiKey;
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://api.openai.com/v1'));

  OpenAIClient(this.apiKey);

  Future<List<AudioSegment>> translateSegments(
    List<AudioSegment> segments,
    String targetLang,
  ) async {
    final prompt = """
Translate the following transcript segments into $targetLang. 
Maintain the speaker IDs and time constraints.
Ensure the translated text is suitable for the duration of the segment.
Return a JSON array of objects with 'speaker_id' and 'translated_text'.

Segments:
${jsonEncode(segments.map((s) => {'speaker_id': s.speakerId, 'text': s.text}).toList())}
""";

    final response = await _dio.post(
      '/chat/completions',
      options: Options(
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
      ),
      data: {
        'model': 'gpt-4o',
        'messages': [
          {'role': 'system', 'content': 'You are a professional translator and dubbing expert.'},
          {'role': 'user', 'content': prompt},
        ],
        'response_format': {'type': 'json_object'},
      },
    );

    if (response.statusCode == 200) {
      final content = response.data['choices'][0]['message']['content'];
      final decoded = jsonDecode(content);
      final translatedArray = decoded['translations'] ?? decoded['segments'] ?? decoded.values.first;

      for (var i = 0; i < segments.length; i++) {
        segments[i].translatedText = translatedArray[i]['translated_text'];
      }
      return segments;
    } else {
      throw Exception('OpenAI translation failed: ${response.statusMessage}');
    }
  }
}
