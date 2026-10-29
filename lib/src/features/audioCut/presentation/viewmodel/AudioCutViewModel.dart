import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

// ================= 1. STATE =================
class AudioCutState {
  final String? audioPath;
  final String? audioName;
  final double totalDurationSec;
  final double startSec;
  final double endSec;
  final double currentPosSec;
  final bool isPlaying;
  final bool isInitialized;
  final bool isCutting;
  final double playbackSpeed;
  final bool isTrimSides;
  final String? outputAudioPath;
  final String? errorMessage;

  const AudioCutState({
    this.audioPath,
    this.audioName,
    this.totalDurationSec = 0.0,
    this.startSec = 0.0,
    this.endSec = 0.0,
    this.currentPosSec = 0.0,
    this.isPlaying = false,
    this.isInitialized = false,
    this.isCutting = false,
    this.playbackSpeed = 1.0,
    this.isTrimSides = true,
    this.outputAudioPath,
    this.errorMessage,
  });

  AudioCutState copyWith({
    String? audioPath,
    String? audioName,
    double? totalDurationSec,
    double? startSec,
    double? endSec,
    double? currentPosSec,
    bool? isPlaying,
    bool? isInitialized,
    bool? isCutting,
    double? playbackSpeed,
    bool? isTrimSides,
    String? outputAudioPath,
    String? errorMessage,
  }) {
    return AudioCutState(
      audioPath: audioPath ?? this.audioPath,
      audioName: audioName ?? this.audioName,
      totalDurationSec: totalDurationSec ?? this.totalDurationSec,
      startSec: startSec ?? this.startSec,
      endSec: endSec ?? this.endSec,
      currentPosSec: currentPosSec ?? this.currentPosSec,
      isPlaying: isPlaying ?? this.isPlaying,
      isInitialized: isInitialized ?? this.isInitialized,
      isCutting: isCutting ?? this.isCutting,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      isTrimSides: isTrimSides ?? this.isTrimSides,
      outputAudioPath: outputAudioPath ?? this.outputAudioPath,
      errorMessage: errorMessage,
    );
  }
}

// ================= 2. VIEWMODEL =================
class AudioCutViewModel extends StateNotifier<AudioCutState> {
  VideoPlayerController? _player;

  AudioCutViewModel() : super(const AudioCutState());

  Future<void> initAudio(String path, String name) async {
    state = state.copyWith(
      audioPath: path,
      audioName: name,
      isInitialized: false,
      isPlaying: false,
      playbackSpeed: 1.0,
    );

    try {
      if (_player != null) {
        await _player!.dispose();
        _player = null;
      }

      _player = VideoPlayerController.file(File(path));
      await _player!.initialize();
      await _player!.setPlaybackSpeed(1.0);

      final duration = _player!.value.duration.inMilliseconds / 1000.0;

      state = state.copyWith(
        totalDurationSec: duration,
        startSec: 0.0,
        endSec: duration,
        currentPosSec: 0.0,
        isInitialized: true,
      );

      _player!.addListener(() {
        if (_player == null || !_player!.value.isInitialized) return;
        final pos = _player!.value.position.inMilliseconds / 1000.0;

        state = state.copyWith(
          currentPosSec: pos,
          isPlaying: _player!.value.isPlaying,
        );

        if (_player!.value.isPlaying && pos >= state.endSec) {
          seekTo(state.startSec);
          _player!.pause();
        }
      });
    } catch (e) {
      state = state.copyWith(
        isInitialized: false,
        errorMessage: 'Audio load error: $e',
      );
    }
  }

  // ✅ Fixed Playback Speed Control (Async + Safe apply)
  Future<void> setPlaybackSpeed(double speed) async {
    state = state.copyWith(playbackSpeed: speed);
    if (_player != null && _player!.value.isInitialized) {
      try {
        await _player!.setPlaybackSpeed(speed);
      } catch (e) {
        debugPrint('Error setting playback speed: $e');
      }
    }
  }

  // ✅ Fixed togglePlay (Play karte waqt selected speed apply hogi)
  Future<void> togglePlay() async {
    if (_player == null || !_player!.value.isInitialized) return;
    if (_player!.value.isPlaying) {
      await _player!.pause();
    } else {
      if (state.currentPosSec < state.startSec || state.currentPosSec >= state.endSec) {
        seekTo(state.startSec);
      }
      // Selected speed ko play karne se pehle aur baad enforce karein
      await _player!.setPlaybackSpeed(state.playbackSpeed);
      await _player!.play();
      await _player!.setPlaybackSpeed(state.playbackSpeed);
    }
  }

  void seekTo(double sec) {
    if (_player == null || !_player!.value.isInitialized) return;
    final clamped = sec.clamp(0.0, state.totalDurationSec);
    _player!.seekTo(Duration(milliseconds: (clamped * 1000).toInt()));
    // Seek karne ke baad bhi speed reset na ho
    _player!.setPlaybackSpeed(state.playbackSpeed);
    state = state.copyWith(currentPosSec: clamped);
  }

  void seekBy(double deltaSec) {
    seekTo(state.currentPosSec + deltaSec);
  }

  void skipToStart() => seekTo(state.startSec);
  void skipToEnd() => seekTo(state.endSec);

  void updateStartSec(double sec) {
    final clamped = sec.clamp(0.0, state.endSec - 0.2);
    state = state.copyWith(startSec: clamped, currentPosSec: clamped);
  }

  void updateEndSec(double sec) {
    final clamped = sec.clamp(state.startSec + 0.2, state.totalDurationSec);
    state = state.copyWith(endSec: clamped, currentPosSec: clamped);
  }

  void adjustStart(double delta) {
    updateStartSec(state.startSec + delta);
    seekTo(state.startSec);
  }

  void adjustEnd(double delta) {
    updateEndSec(state.endSec + delta);
    seekTo(state.endSec);
  }

  void setTrimMode(bool isSides) {
    state = state.copyWith(isTrimSides: isSides);
  }

  void pause() => _player?.pause();

  @override
  void dispose() {
    _player?.dispose();
    super.dispose();
  }
}

// Provider
final audioCutViewModelProvider =
    StateNotifierProvider<AudioCutViewModel, AudioCutState>((ref) {
  return AudioCutViewModel();
});