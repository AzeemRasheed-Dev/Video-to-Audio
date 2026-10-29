import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'converter_providers.dart';

// --- 1. Cut State ---
class CutState {
  final double startSec;
  final double endSec;
  final double totalDurationSec;
  final double currentPosSec;
  final bool isPlaying;
  final bool isInitialized;
  final List<String> thumbnailPaths;

  const CutState({
    this.startSec = 0.0,
    this.endSec = 10.0,
    this.totalDurationSec = 10.0,
    this.currentPosSec = 0.0,
    this.isPlaying = false,
    this.isInitialized = false,
    this.thumbnailPaths = const [],
  });

  CutState copyWith({
    double? startSec,
    double? endSec,
    double? totalDurationSec,
    double? currentPosSec,
    bool? isPlaying,
    bool? isInitialized,
    List<String>? thumbnailPaths,
  }) {
    return CutState(
      startSec: startSec ?? this.startSec,
      endSec: endSec ?? this.endSec,
      totalDurationSec: totalDurationSec ?? this.totalDurationSec,
      currentPosSec: currentPosSec ?? this.currentPosSec,
      isPlaying: isPlaying ?? this.isPlaying,
      isInitialized: isInitialized ?? this.isInitialized,
      thumbnailPaths: thumbnailPaths ?? this.thumbnailPaths,
    );
  }
}

// --- 2. Cut ViewModel (All Business Logic) ---
class CutViewModel extends StateNotifier<CutState> {
  VideoPlayerController? controller;

  CutViewModel(String videoPath, double initStart, double initEnd, double initDuration)
      : super(CutState(
          startSec: initStart,
          endSec: initEnd > 0 ? initEnd : 10.0,
          totalDurationSec: initDuration > 0 ? initDuration : 10.0,
          currentPosSec: initStart,
        )) {
    if (videoPath.isNotEmpty) {
      _initVideo(videoPath);
    }
  }

  Future<void> _initVideo(String videoPath) async {
    try {
      controller = VideoPlayerController.file(File(videoPath));
      await controller!.initialize();

      final total = controller!.value.duration.inMilliseconds / 1000.0;
      state = state.copyWith(
        isInitialized: true,
        totalDurationSec: total,
        endSec: state.endSec > total || state.endSec == 0 ? total : state.endSec,
        currentPosSec: state.startSec,
      );

      _extractThumbnails(videoPath, total);

      controller!.addListener(() {
        if (controller == null) return;
        if (controller!.value.isPlaying) {
          final pos = controller!.value.position.inMilliseconds / 1000.0;
          if (pos >= state.endSec) {
            seekTo(state.startSec);
            controller!.pause();
            state = state.copyWith(currentPosSec: state.startSec, isPlaying: false);
          } else {
            state = state.copyWith(currentPosSec: pos, isPlaying: true);
          }
        } else {
          if (state.isPlaying) {
            state = state.copyWith(isPlaying: false);
          }
        }
      });
    } catch (_) {}
  }

  // Handle Drag / Time Change Logic:
  void updateStart(double newStart) {
    final clamped = newStart.clamp(0.0, state.endSec - 0.5);
    state = state.copyWith(startSec: clamped, currentPosSec: clamped);
  }

  void updateEnd(double newEnd) {
    final clamped = newEnd.clamp(state.startSec + 0.5, state.totalDurationSec);
    state = state.copyWith(endSec: clamped, currentPosSec: clamped);
  }

  void seekTo(double sec) {
    controller?.seekTo(Duration(milliseconds: (sec * 1000).toInt()));
  }

  void togglePlay() {
    if (controller == null) return;
    if (controller!.value.isPlaying) {
      controller!.pause();
      state = state.copyWith(isPlaying: false);
    } else {
      if (state.currentPosSec >= state.endSec || state.currentPosSec < state.startSec) {
        seekTo(state.startSec);
        state = state.copyWith(currentPosSec: state.startSec);
      }
      controller!.play();
      state = state.copyWith(isPlaying: true);
    }
  }

  void rewindToStart() {
    seekTo(state.startSec);
    state = state.copyWith(currentPosSec: state.startSec);
  }

  Future<void> _extractThumbnails(String videoPath, double duration) async {
    try {
      final tempDir = Directory.systemTemp;
      final step = duration / 8;
      List<String> frames = [];

      for (int i = 0; i < 8; i++) {
        final timeSec = (i * step).toStringAsFixed(1);
        final out = '${tempDir.path}/thumb_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        final cmd = '-ss $timeSec -i "$videoPath" -vframes 1 -q:v 3 -s 120x70 -y "$out"';
        await FFmpegKit.execute(cmd);
        if (File(out).existsSync()) frames.add(out);
      }

      if (frames.isNotEmpty) {
        state = state.copyWith(thumbnailPaths: frames);
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}

// AutoDispose Provider (Screen band hone par controller khud dispose hoga):
final cutViewModelProvider = StateNotifierProvider.autoDispose<CutViewModel, CutState>((ref) {
  final convState = ref.watch(converterViewModelProvider);
  return CutViewModel(
    convState.videoPath ?? '',
    convState.cutStartSec,
    convState.cutEndSec,
    convState.videoDurationSec,
  );
});