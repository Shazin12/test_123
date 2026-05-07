# AI Dub Pro (Pure Dart)

A 100% Dart-based AI Dubbing System that eliminates the need for a local Python backend by using cloud APIs for all-in-one transcription, diarization, translation, voice cloning, and lip-sync.

## Architecture

1.  **Audio Extraction**: Uses `ffmpeg_kit_flutter_full_gpl` to extract high-quality audio from the source video.
2.  **Transcription & Diarization**: Uses the **Deepgram Nova-2** API for sub-second, multi-speaker diarization and word-level timestamps.
3.  **Semantic Translation**: Uses **OpenAI GPT-4o** with duration-aware prompts to translate segments while preserving pacing and meaning.
4.  **Voice Cloning & TTS**: Uses **ElevenLabs** "Instant Voice Cloning" to clone speakers from 30s samples and synthesize dubbed audio.
5.  **Lip-Sync**: Uses **Sync Labs** API to synchronize the original video with the new dubbed audio track.

## Features

-   Cross-platform: Android, iOS, Web, and Desktop (Linux).
-   API-First: No heavy ML models to manage locally.
-   Modern UI: Built with Flutter Material 3.
-   Real-time Progress Tracking.

## Getting Started

1.  Install Flutter.
2.  Run `flutter pub get`.
3.  Configure your API keys in the app UI.
4.  Run `flutter run`.

## Project Structure

- `lib/core/api/`: REST clients for all external services.
- `lib/core/ffmpeg/`: Native media handling logic.
- `lib/features/dubbing/`: Orchestration and pipeline management.
- `lib/features/upload/`: UI for video selection and configuration.
