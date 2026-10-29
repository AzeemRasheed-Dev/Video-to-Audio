import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';

// ================= STATE =================
class VideoCutState {
  final String? videoPath;
  final String? videoName;
  final double totalDurationSec;
  final double startSec;
  final double endSec;
  final double currentPosSec;
  final bool isPlaying;
  final bool isInitialized;
  final bool isCutting;
  final double outputVolume; // 1.0 = 100%, 1.49 = 149%
  final String? outputVideoPath;
  final String? errorMessage;
  // 👉 QA Bug iv Fix: Real video thumbnails list
  final List<String>? thumbnails;

  const VideoCutState({
    this.videoPath,
    this.videoName,
    this.totalDurationSec = 0.0,
    this.startSec = 0.0,
    this.endSec = 0.0,
    this.currentPosSec = 0.0,
    this.isPlaying = false,
    this.isInitialized = false,
    this.isCutting = false,
    this.outputVolume = 1.0,
    this.outputVideoPath,
    this.errorMessage,
    this.thumbnails,
  });

  VideoCutState copyWith({
    String? videoPath,
    String? videoName,
    double? totalDurationSec,
    double? startSec,
    double? endSec,
    double? currentPosSec,
    bool? isPlaying,
    bool? isInitialized,
    bool? isCutting,
    double? outputVolume,
    String? outputVideoPath,
    String? errorMessage,
    List<String>? thumbnails,
  }) {
    return VideoCutState(
      videoPath: videoPath ?? this.videoPath,
      videoName: videoName ?? this.videoName,
      totalDurationSec: totalDurationSec ?? this.totalDurationSec,
      startSec: startSec ?? this.startSec,
      endSec: endSec ?? this.endSec,
      currentPosSec: currentPosSec ?? this.currentPosSec,
      isPlaying: isPlaying ?? this.isPlaying,
      isInitialized: isInitialized ?? this.isInitialized,
      isCutting: isCutting ?? this.isCutting,
      outputVolume: outputVolume ?? this.outputVolume,
      outputVideoPath: outputVideoPath ?? this.outputVideoPath,
      errorMessage: errorMessage,
      thumbnails: thumbnails ?? this.thumbnails,
    );
  }
}

// ================= VIEWMODEL =================
class VideoCutViewModel extends StateNotifier<VideoCutState> {
  VideoCutViewModel() : super(const VideoCutState());

  VideoPlayerController? playerController;

  // Video initialize karna
  Future<void> initVideo(String path, String name) async {
    await playerController?.dispose();
    playerController = null;

    state = VideoCutState(videoPath: path, videoName: name);

    try {
      playerController = VideoPlayerController.file(File(path));
      await playerController!.initialize();

      final total = playerController!.value.duration.inMilliseconds / 1000.0;

      state = state.copyWith(
        totalDurationSec: total,
        startSec: 0.0,
        endSec: total,
        currentPosSec: 0.0,
        isInitialized: true,
        isPlaying: false,
      );

      // 👉 QA Bug iv Fix: Background me 8 thumbnails extract karega (UI freeze kiye baghair)
      _generateThumbnails(path, total);

      playerController!.addListener(() {
        if (playerController != null && playerController!.value.isInitialized) {
          final pos = playerController!.value.position.inMilliseconds / 1000.0;
          if (pos >= state.endSec) {
            playerController!.pause();
            playerController!.seekTo(Duration(milliseconds: (state.startSec * 1000).toInt()));
            state = state.copyWith(isPlaying: false, currentPosSec: state.startSec);
          } else {
            state = state.copyWith(
              currentPosSec: pos,
              isPlaying: playerController!.value.isPlaying,
            );
          }
        }
      });
    } catch (e) {
      state = state.copyWith(errorMessage: 'Video load failed: $e');
    }
  }

  // Fast background thumbnail generation
  Future<void> _generateThumbnails(String videoPath, double durationSec) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final thumbDir = Directory(
        '${tempDir.path}/thumbs_${DateTime.now().millisecondsSinceEpoch}',
      );
      if (!await thumbDir.exists()) {
        await thumbDir.create(recursive: true);
      }

      final safeDuration = durationSec > 0 ? durationSec : 1.0;
      final fps = 8.0 / safeDuration;

      // Extract 8 scaled down frames
      final cmd = '-y -i "$videoPath" -vf "fps=$fps,scale=140:-1" -vframes 8 "${thumbDir.path}/thumb_%02d.jpg"';

      await FFmpegKit.executeAsync(cmd, (session) async {
        final returnCode = await session.getReturnCode();
        if (ReturnCode.isSuccess(returnCode)) {
          final files = thumbDir
              .listSync()
              .where((f) => f.path.endsWith('.jpg'))
              .map((f) => f.path)
              .toList()
            ..sort();

          if (files.isNotEmpty && mounted) {
            state = state.copyWith(thumbnails: files);
          }
        }
      });
    } catch (_) {}
  }

  void updateStartSec(double sec) {
    if (sec < 0) sec = 0;
    if (sec > state.endSec - 0.5) sec = state.endSec - 0.5;
    state = state.copyWith(startSec: sec);
    playerController?.seekTo(Duration(milliseconds: (sec * 1000).toInt()));
  }

  void updateEndSec(double sec) {
    if (sec > state.totalDurationSec) sec = state.totalDurationSec;
    if (sec < state.startSec + 0.5) sec = state.startSec + 0.5;
    state = state.copyWith(endSec: sec);
  }

  void adjustStart(double delta) => updateStartSec(state.startSec + delta);
  void adjustEnd(double delta) => updateEndSec(state.endSec + delta);

  // Buttons: "set to start" aur "set to end"
  void setToStart() => updateStartSec(state.currentPosSec);
  void setToEnd() => updateEndSec(state.currentPosSec);

  void seekTo(double sec) {
    if (sec < state.startSec) sec = state.startSec;
    if (sec > state.endSec) sec = state.endSec;
    playerController?.seekTo(Duration(milliseconds: (sec * 1000).toInt()));
    state = state.copyWith(currentPosSec: sec);
  }

  void togglePlayPause() {
    if (playerController == null || !state.isInitialized) return;
    if (playerController!.value.isPlaying) {
      playerController!.pause();
      state = state.copyWith(isPlaying: false);
    } else {
      if (state.currentPosSec >= state.endSec || state.currentPosSec < state.startSec) {
        seekTo(state.startSec);
      }
      playerController!.play();
      state = state.copyWith(isPlaying: true);
    }
  }

  void setOutputVolume(double vol) {
    state = state.copyWith(outputVolume: vol);
  }

  // FFmpeg se Video Cut karna
  Future<String?> cutVideo() async {
    if (state.videoPath == null) return null;
    state = state.copyWith(isCutting: true, errorMessage: null);

    try {
      final tempDir = await getApplicationDocumentsDirectory();
      final outDir = Directory('${tempDir.path}/CutVideos');
      if (!await outDir.exists()) {
        await outDir.create(recursive: true);
      }

      final ext = state.videoPath!.split('.').last;
      final outPath = '${outDir.path}/video_cut_${DateTime.now().millisecondsSinceEpoch}.$ext';
      final duration = state.endSec - state.startSec;

      // Volume & Codec selection
      final bool hasCustomVolume = state.outputVolume != 1.0;
      final String audioArgs = hasCustomVolume
          ? '-filter:a "volume=${state.outputVolume}" -c:a aac'
          : '-c:a copy';

      final cmd = '-y -ss ${state.startSec.toStringAsFixed(2)} -t ${duration.toStringAsFixed(2)} -i "${state.videoPath}" -c:v copy $audioArgs "$outPath"';

      final session = await FFmpegKit.execute(cmd);
      final returnCode = await session.getReturnCode();

      state = state.copyWith(isCutting: false);

      if (ReturnCode.isSuccess(returnCode)) {
        state = state.copyWith(outputVideoPath: outPath);
        return outPath;
      } else {
        state = state.copyWith(errorMessage: 'Video cutting failed');
        return null;
      }
    } catch (e) {
      state = state.copyWith(isCutting: false, errorMessage: e.toString());
      return null;
    }
  }

  @override
  void dispose() {
    playerController?.dispose();
    super.dispose();
  }
}

// ================= PROVIDER =================
final videoCutViewModelProvider =
    StateNotifierProvider<VideoCutViewModel, VideoCutState>((ref) {
  return VideoCutViewModel();
});