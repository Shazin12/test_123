import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ElevenLabsClient {
  final String apiKey;
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://api.elevenlabs.io/v1'));

  ElevenLabsClient(this.apiKey);

  Future<String> cloneVoice(String name, File sampleFile) async {
    final formData = FormData.fromMap({
      'name': name,
      'files': await MultipartFile.fromFile(sampleFile.path, filename: 'sample.wav'),
    });

    final response = await _dio.post(
      '/voices/add',
      data: formData,
      options: Options(headers: {'xi-api-key': apiKey}),
    );

    if (response.statusCode == 200) {
      return response.data['voice_id'];
    } else {
      throw Exception('ElevenLabs voice cloning failed: ${response.statusMessage}');
    }
  }

  Future<File> synthesize(String text, String voiceId, String outputFileName) async {
    final response = await _dio.post(
      '/text-to-speech/$voiceId',
      data: {
        'text': text,
        'model_id': 'eleven_multilingual_v2',
        'voice_settings': {
          'stability': 0.5,
          'similarity_boost': 0.75,
        },
      },
      options: Options(
        headers: {'xi-api-key': apiKey},
        responseType: ResponseType.bytes,
      ),
    );

    if (response.statusCode == 200) {
      final tempDir = await getTemporaryDirectory();
      final file = File(p.join(tempDir.path, outputFileName));
      await file.writeAsBytes(response.data);
      return file;
    } else {
      throw Exception('ElevenLabs synthesis failed: ${response.statusMessage}');
    }
  }
}
