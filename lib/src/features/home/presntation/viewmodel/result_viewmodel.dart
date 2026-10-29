import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import '../../services/storage_service.dart';
import 'converter_providers.dart';

// 1. Result State
class ResultState {
  final bool isInitialized;
  final bool isPlaying;
  final double currentPosSec;
  final double totalDurSec;

  const ResultState({
    this.isInitialized = false,
    this.isPlaying = false,
    this.currentPosSec = 0.0,
    this.totalDurSec = 0.0,
  });

  ResultState copyWith({
    bool? isInitialized,
    bool? isPlaying,
    double? currentPosSec,
    double? totalDurSec,
  }) {
    return ResultState(
      isInitialized: isInitialized ?? this.isInitialized,
      isPlaying: isPlaying ?? this.isPlaying,
      currentPosSec: currentPosSec ?? this.currentPosSec,
      totalDurSec: totalDurSec ?? this.totalDurSec,
    );
  }
}

// 2. Result ViewModel
class ResultViewModel extends StateNotifier<ResultState> {
  final StorageService _storageService;
  final String? audioPath;
  VideoPlayerController? _player;

  ResultViewModel({
    required StorageService storageService,
    required this.audioPath,
  })  : _storageService = storageService,
        super(const ResultState()) {
    if (audioPath != null) {
      _initAudio(audioPath!);
    }
  }

  Future<void> _initAudio(String path) async {
    try {
      _player = VideoPlayerController.file(File(path));
      await _player!.initialize();
      final dur = _player!.value.duration.inMilliseconds / 1000.0;

      state = state.copyWith(
        isInitialized: true,
        totalDurSec: dur,
      );

      _player!.addListener(() {
        if (_player == null) return;
        final pos = _player!.value.position.inMilliseconds / 1000.0;
        state = state.copyWith(
          currentPosSec: pos,
          isPlaying: _player!.value.isPlaying,
        );
      });
    } catch (_) {}
  }

  void togglePlay() {
    if (_player == null) return;
    if (_player!.value.isPlaying) {
      _player!.pause();
    } else {
      if (state.currentPosSec >= state.totalDurSec) {
        _player!.seekTo(Duration.zero);
      }
      _player!.play();
    }
  }

  void seekTo(double sec) {
    _player?.seekTo(Duration(milliseconds: (sec * 1000).toInt()));
  }

  // Save to Downloads
  Future<String?> saveToDownloads(String? videoName, String format) async {
    if (audioPath == null) return null;
    final base = videoName?.split('.').first ?? 'audio';
    return await _storageService.saveToDownloadsDirectory(
      sourceAudioPath: audioPath!,
      targetFileName: '$base.$format',
    );
  }

  // Share
  Future<void> shareAudio() async {
    if (audioPath != null) {
      await _storageService.shareAudioFile(audioPath!);
    }
  }

  // Set Ringtone
  Future<bool> setRingtone() async {
    if (audioPath != null) {
      return await _storageService.setAudioAsRingtone(audioPath!);
    }
    return false;
  }

  // Open External
  Future<void> openExternal() async {
    if (audioPath != null) {
      await _storageService.openAudioFile(audioPath!);
    }
  }

  @override
  void dispose() {
    _player?.dispose();
    super.dispose();
  }
}

// 3. AutoDispose Provider
final resultViewModelProvider =
    StateNotifierProvider.autoDispose<ResultViewModel, ResultState>((ref) {
  final storage = ref.watch(storageServiceProvider);
  final audioPath = ref.watch(converterViewModelProvider).audioPath;
  return ResultViewModel(
    storageService: storage,
    audioPath: audioPath,
  );
});