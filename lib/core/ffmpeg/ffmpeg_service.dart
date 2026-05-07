import 'dart:io';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/return_code.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class FFmpegService {
  Future<File> extractAudio(File videoFile) async {
    final tempDir = await getTemporaryDirectory();
    final outputPath = p.join(tempDir.path, 'original_audio.wav');
    
    // -i input -vn (no video) -acodec pcm_s16le -ar 16000 -ac 1 output
    final session = await FFmpegKit.execute('-i ${videoFile.path} -vn -acodec pcm_s16le -ar 16000 -ac 1 -y $outputPath');
    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      return File(outputPath);
    } else {
      final logs = await session.getLogs();
      throw Exception('FFmpeg audio extraction failed: ${logs.join('\n')}');
    }
  }

  Future<File> extractVoiceSample(File audioFile, double start, double duration) async {
    final tempDir = await getTemporaryDirectory();
    final outputPath = p.join(tempDir.path, 'voice_sample_${DateTime.now().millisecondsSinceEpoch}.wav');

    final session = await FFmpegKit.execute('-ss $start -t $duration -i ${audioFile.path} -acodec copy -y $outputPath');
    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      return File(outputPath);
    } else {
      throw Exception('FFmpeg voice sample extraction failed');
    }
  }

  Future<File> mergeAudioSegments(List<String> audioPaths, List<double> startTimes) async {
    final tempDir = await getTemporaryDirectory();
    final outputPath = p.join(tempDir.path, 'dubbed_audio_timeline.wav');
    
    // This is a bit complex in FFmpeg. We need to use the 'amix' or 'adelay' filter.
    // For simplicity in this orchestrator, we'll build a complex filter string.
    
    String filterComplex = '';
    for (int i = 0; i < audioPaths.length; i++) {
      final delayMs = (startTimes[i] * 1000).toInt();
      filterComplex += '[$i]adelay=$delayMs|$delayMs[a$i];';
    }
    
    String inputs = '';
    String mix = '';
    for (int i = 0; i < audioPaths.length; i++) {
      inputs += '-i ${audioPaths[i]} ';
      mix += '[a$i]';
    }
    mix += 'amix=inputs=${audioPaths.length}:duration=first[out]';
    
    final session = await FFmpegKit.execute('$inputs -filter_complex "${filterComplex}${mix}" -map "[out]" -y $outputPath');
    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      return File(outputPath);
    } else {
      throw Exception('FFmpeg audio merging failed');
    }
  }
}
