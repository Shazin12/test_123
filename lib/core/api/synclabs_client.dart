import 'package:dio/dio.dart';

class SyncLabsClient {
  final String apiKey;
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://api.synclabs.so/v1'));

  SyncLabsClient(this.apiKey);

  Future<String> syncLip(String videoUrl, String audioUrl) async {
    final response = await _dio.post(
      '/video',
      data: {
        'video_url': videoUrl,
        'audio_url': audioUrl,
        'model': 'sync-1.5',
      },
      options: Options(headers: {'x-api-key': apiKey}),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return response.data['id'];
    } else {
      throw Exception('Sync Labs lip-sync failed: ${response.statusMessage}');
    }
  }

  Future<Map<String, dynamic>> getJobStatus(String jobId) async {
    final response = await _dio.get(
      '/video/$jobId',
      options: Options(headers: {'x-api-key': apiKey}),
    );
    return response.data;
  }
}
