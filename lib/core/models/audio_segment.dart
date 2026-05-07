class AudioSegment {
  final double start;
  final double end;
  final String text;
  final int speakerId;
  String? translatedText;
  String? synthesizedAudioPath;

  AudioSegment({
    required this.start,
    required this.end,
    required this.text,
    required this.speakerId,
    this.translatedText,
    this.synthesizedAudioPath,
  });

  double get duration => end - start;

  Map<String, dynamic> toJson() => {
    'start': start,
    'end': end,
    'text': text,
    'speaker_id': speakerId,
    'translated_text': translatedText,
    'synthesized_audio_path': synthesizedAudioPath,
  };

  factory AudioSegment.fromJson(Map<String, dynamic> json) => AudioSegment(
    start: (json['start'] as num).toDouble(),
    end: (json['end'] as num).toDouble(),
    text: json['text'] as String,
    speakerId: json['speaker_id'] as int,
    translatedText: json['translated_text'] as String?,
    synthesizedAudioPath: json['synthesized_audio_path'] as String?,
  );
}
