import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/src/features/output/model/output_file_item.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

// ================= STATE =================
class OutputState {
  final List<OutputFileItem> audioFiles;
  final List<OutputFileItem> videoFiles;
  final bool isLoading;

  const OutputState({
    this.audioFiles = const [],
    this.videoFiles = const [],
    this.isLoading = false,
  });

  OutputState copyWith({
    List<OutputFileItem>? audioFiles,
    List<OutputFileItem>? videoFiles,
    bool? isLoading,
  }) {
    return OutputState(
      audioFiles: audioFiles ?? this.audioFiles,
      videoFiles: videoFiles ?? this.videoFiles,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// ================= VIEWMODEL =================
class OutputViewModel extends StateNotifier<OutputState> {
  OutputViewModel() : super(const OutputState()) {
    loadFiles();
  }

  // Saari saved files scan karna
  Future<void> loadFiles() async {
    state = state.copyWith(isLoading: true);

    try {
      final docDir = await getApplicationDocumentsDirectory();
      final tempDir = await getTemporaryDirectory();

      final Set<String> seenPaths = {};

      // 1. Scan Audios (ConvertedAudios, CutAudios, and Temp cache fallback)
      final List<OutputFileItem> audios = [];
      final audioDirs = [
        Directory('${docDir.path}/ConvertedAudios'),
        Directory('${docDir.path}/CutAudios'),
        docDir,
        tempDir, // Fallback for past conversions
      ];

      for (final dir in audioDirs) {
        if (await dir.exists()) {
          final entities = dir.listSync();
          for (final entity in entities) {
            if (entity is File && !seenPaths.contains(entity.path)) {
              final ext = entity.path.split('.').last.toLowerCase();
              if (['mp3', 'm4a', 'aac', 'wav', 'opus', 'ogg'].contains(ext)) {
                seenPaths.add(entity.path);
                final stat = await entity.stat();
                audios.add(
                  OutputFileItem(
                    path: entity.path,
                    name: entity.path.split(Platform.pathSeparator).last,
                    sizeInBytes: stat.size,
                    modifiedDate: stat.modified,
                    isVideo: false,
                  ),
                );
              }
            }
          }
        }
      }

      // Sort newest first
      audios.sort((a, b) => b.modifiedDate.compareTo(a.modifiedDate));

      // 2. Scan Videos (CutVideos & ConvertedVideos)
      final List<OutputFileItem> videos = [];
      final videoDirs = [
        Directory('${docDir.path}/CutVideos'),
        Directory('${docDir.path}/ConvertedVideos'),
      ];

      for (final videoDir in videoDirs) {
        if (await videoDir.exists()) {
          final entities = videoDir.listSync();
          for (final entity in entities) {
            if (entity is File && !seenPaths.contains(entity.path)) {
              final ext = entity.path.split('.').last.toLowerCase();
              if (['mp4', 'mkv', 'mov', '3gp', 'webm'].contains(ext)) {
                seenPaths.add(entity.path);
                final stat = await entity.stat();
                videos.add(
                  OutputFileItem(
                    path: entity.path,
                    name: entity.path.split(Platform.pathSeparator).last,
                    sizeInBytes: stat.size,
                    modifiedDate: stat.modified,
                    isVideo: true,
                  ),
                );
              }
            }
          }
        }
      }

      videos.sort((a, b) => b.modifiedDate.compareTo(a.modifiedDate));

      state = state.copyWith(
        audioFiles: audios,
        videoFiles: videos,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  // File Open karna
  void openFile(OutputFileItem file) {
    OpenFile.open(file.path);
  }

  // File Share karna
  void shareFile(OutputFileItem file) {
    Share.shareXFiles([XFile(file.path)], text: file.name);
  }

  // File Delete karna
  Future<void> deleteFile(OutputFileItem file) async {
    try {
      final f = File(file.path);
      if (await f.exists()) {
        await f.delete();
      }
      // Re-scan
      await loadFiles();
    } catch (_) {}
  }
}

// ================= PROVIDER =================
final outputViewModelProvider =
    StateNotifierProvider<OutputViewModel, OutputState>((ref) {
      return OutputViewModel();
    });
  