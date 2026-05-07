import 'dart:io';
import 'package:dio/dio.dart';
import '../models/audio_segment.dart';

class DeepgramClient {
  final String apiKey;
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://api.deepgram.com/v1'));

  DeepgramClient(this.apiKey);

  Future<List<AudioSegment>> transcribeAndDiarize(File audioFile) async {
    final response = await _dio.post(
      '/listen',
      data: audioFile.openRead(),
      options: Options(
        headers: {
          'Authorization': 'Token $apiKey',
          'Content-Type': 'audio/wav',
        },
      ),
      queryParameters: {
        'diarize': 'true',
        'punctuate': 'true',
        'utterances': 'true',
        'model': 'nova-2',
        'smart_format': 'true',
      },
    );

    if (response.statusCode == 200) {
      final results = response.data['results'];
      final utterances = results['utterances'] as List;
      
      return utterances.map((u) => AudioSegment(
        start: (u['start'] as num).toDouble(),
        end: (u['end'] as num).toDouble(),
        text: u['transcript'] as String,
        speakerId: u['speaker'] as int,
      )).toList();
    } else {
      throw Exception('Deepgram transcription failed: ${response.statusMessage}');
    }
  }
}
