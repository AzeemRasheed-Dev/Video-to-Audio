import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

// ================= STATE =================
class AudioSavedState {
  final String audioPath;
  final String fileName;
  final double currentPosSec;
  final double totalDurationSec;
  final bool isPlaying;
  final bool isInitialized;
  final String? message;

  const AudioSavedState({
    this.audioPath = '',
    this.fileName = '',
    this.currentPosSec = 0.0,
    this.totalDurationSec = 0.0,
    this.isPlaying = false,
    this.isInitialized = false,
    this.message,
  });

  AudioSavedState copyWith({
    String? audioPath,
    String? fileName,
    double? currentPosSec,
    double? totalDurationSec,
    bool? isPlaying,
    bool? isInitialized,
    String? message,
  }) {
    return AudioSavedState(
      audioPath: audioPath ?? this.audioPath,
      fileName: fileName ?? this.fileName,
      currentPosSec: currentPosSec ?? this.currentPosSec,
      totalDurationSec: totalDurationSec ?? this.totalDurationSec,
      isPlaying: isPlaying ?? this.isPlaying,
      isInitialized: isInitialized ?? this.isInitialized,
      message: message,
    );
  }
}

// ================= VIEWMODEL =================
class AudioSavedViewModel extends StateNotifier<AudioSavedState> {
  AudioSavedViewModel() : super(const AudioSavedState());

  VideoPlayerController? _player;

  Future<void> initAudio(String filePath) async {
    await _player?.dispose();
    _player = null;

    final name = filePath.split(Platform.pathSeparator).last;
    state = AudioSavedState(audioPath: filePath, fileName: name);

    try {
      _player = VideoPlayerController.file(File(filePath));
      await _player!.initialize();

      final total = _player!.value.duration.inMilliseconds / 1000.0;
      state = state.copyWith(totalDurationSec: total, isInitialized: true);

      _player!.addListener(() {
        if (_player != null && _player!.value.isInitialized) {
          final pos = _player!.value.position.inMilliseconds / 1000.0;
          if (pos >= state.totalDurationSec) {
            _player!.pause();
            _player!.seekTo(Duration.zero);
            state = state.copyWith(isPlaying: false, currentPosSec: 0.0);
          } else {
            state = state.copyWith(
              currentPosSec: pos,
              isPlaying: _player!.value.isPlaying,
            );
          }
        }
      });
    } catch (e) {
      state = state.copyWith(message: 'Failed to load audio: $e');
    }
  }

  void togglePlayPause() {
    if (_player == null || !state.isInitialized) return;
    if (_player!.value.isPlaying) {
      _player!.pause();
      state = state.copyWith(isPlaying: false);
    } else {
      _player!.play();
      state = state.copyWith(isPlaying: true);
    }
  }

  void seekTo(double sec) {
    if (_player == null || !state.isInitialized) return;
    _player!.seekTo(Duration(milliseconds: (sec * 1000).toInt()));
    state = state.copyWith(currentPosSec: sec);
  }

  // --- 4 Actions Logic ---

  Future<void> downloadToDevice() async {
    try {
      final file = File(state.audioPath);
      if (!await file.exists()) return;

      Directory? downloadDir;
      if (Platform.isAndroid) {
        downloadDir = Directory('/storage/emulated/0/Download');
      } else {
        downloadDir = await getDownloadsDirectory();
      }

      if (downloadDir != null && await downloadDir.exists()) {
        final targetPath = '${downloadDir.path}/${state.fileName}';
        await file.copy(targetPath);
        state = state.copyWith(message: 'Saved to Downloads folder!');
      } else {
        state = state.copyWith(
          message: 'Saved in App storage: ${state.audioPath}',
        );
      }
    } catch (e) {
      state = state.copyWith(message: 'Download error: $e');
    }
  }

  @override
  void dispose() {
    _player?.dispose();
    super.dispose();
  }
}

// ================= PROVIDER =================
final audioSavedViewModelProvider =
    StateNotifierProvider<AudioSavedViewModel, AudioSavedState>((ref) {
      return AudioSavedViewModel();
    });
