import 'dart:io';
import '../../core/api/deepgram_client.dart';
import '../../core/api/openai_client.dart';
import '../../core/api/elevenlabs_client.dart';
import '../../core/api/synclabs_client.dart';
import '../../core/ffmpeg/ffmpeg_service.dart';
import '../../core/models/audio_segment.dart';
import 'package:flutter/foundation.dart';

class DubbingOrchestrator extends ChangeNotifier {
  String status = 'Idle';
  double progress = 0;
  String? resultVideoUrl;
  final FFmpegService ffmpeg = FFmpegService();

  String deepgramKey;
  String openaiKey;
  String elevenlabsKey;
  String synclabsKey;

  DubbingOrchestrator({
    required this.deepgramKey,
    required this.openaiKey,
    required this.elevenlabsKey,
    required this.synclabsKey,
  });

  void updateKeys({
    String? dg,
    String? oa,
    String? el,
    String? sl,
  }) {
    if (dg != null) deepgramKey = dg;
    if (oa != null) openaiKey = oa;
    if (el != null) elevenlabsKey = el;
    if (sl != null) synclabsKey = sl;
    notifyListeners();
  }

  DeepgramClient get _dgClient => DeepgramClient(deepgramKey);
  OpenAIClient get _oaClient => OpenAIClient(openaiKey);
  ElevenLabsClient get _elClient => ElevenLabsClient(elevenlabsKey);
  SyncLabsClient get _slClient => SyncLabsClient(synclabsKey);

  Future<void> runPipeline(File videoFile, String targetLang) async {
    try {
      _updateStatus('Extracting audio...', 0.1);
      final originalAudio = await ffmpeg.extractAudio(videoFile);

      _updateStatus('Transcribing & Diarizing...', 0.2);
      final segments = await _dgClient.transcribeAndDiarize(originalAudio);

      _updateStatus('Translating...', 0.4);
      final translatedSegments = await _oaClient.translateSegments(segments, targetLang);

      _updateStatus('Cloning voices & Synthesizing...', 0.6);
      final uniqueSpeakerIds = translatedSegments.map((s) => s.speakerId).toSet();
      final speakerToVoiceId = <int, String>{};

      for (final speakerId in uniqueSpeakerIds) {
        // Find a good sample for this speaker (e.g., longest segment)
        final speakerSegments = translatedSegments.where((s) => s.speakerId == speakerId).toList();
        speakerSegments.sort((a, b) => b.duration.compareTo(a.duration));
        final bestSegment = speakerSegments.first;
        
        final sample = await ffmpeg.extractVoiceSample(
          originalAudio, 
          bestSegment.start, 
          bestSegment.duration > 30 ? 30 : bestSegment.duration
        );
        
        final voiceId = await _elClient.cloneVoice('Speaker $speakerId', sample);
        speakerToVoiceId[speakerId] = voiceId;
      }

      final synthesizedPaths = <String>[];
      final startTimes = <double>[];

      for (int i = 0; i < translatedSegments.length; i++) {
        final segment = translatedSegments[i];
        final voiceId = speakerToVoiceId[segment.speakerId]!;
        final audioFile = await _elClient.synthesize(
          segment.translatedText!, 
          voiceId, 
          'segment_$i.wav'
        );
        synthesizedPaths.add(audioFile.path);
        startTimes.add(segment.start);
      }

      _updateStatus('Assembling dubbed audio...', 0.8);
      final dubbedAudio = await ffmpeg.mergeAudioSegments(synthesizedPaths, startTimes);

      _updateStatus('Syncing lips (Cloud)...', 0.9);
      // resultVideoUrl = await _slClient.syncLip(videoUrl, dubbedAudioUrl);

      _updateStatus('Completed', 1.0);
    } catch (e) {
      _updateStatus('Error: $e', 0.0);
      rethrow;
    }
  }

  void _updateStatus(String newStatus, double newProgress) {
    status = newStatus;
    progress = newProgress;
    notifyListeners();
  }
}
