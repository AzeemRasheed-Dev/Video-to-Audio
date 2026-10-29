import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

// ================= STATE =================
class VideoSavedState {
  final String videoPath;
  final String fileName;
  final String fileSize;
  final String? message;

  const VideoSavedState({
    this.videoPath = '',
    this.fileName = '',
    this.fileSize = '',
    this.message,
  });

  VideoSavedState copyWith({
    String? videoPath,
    String? fileName,
    String? fileSize,
    String? message,
  }) {
    return VideoSavedState(
      videoPath: videoPath ?? this.videoPath,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      message: message,
    );
  }
}

// ================= VIEWMODEL =================
class VideoSavedViewModel extends StateNotifier<VideoSavedState> {
  VideoSavedViewModel() : super(const VideoSavedState());

  // 1. Initialize Video Info
  Future<void> initVideo(String path) async {
    final file = File(path);
    // Safe extraction regardless of slash type (/ or \)
    final name = path.split(RegExp(r'[/\\]')).last;

    String sizeStr = '0.0 MB';
    if (await file.exists()) {
      final bytes = await file.length();
      final mb = bytes / (1024 * 1024);
      sizeStr = '${mb.toStringAsFixed(1)} MB';
    }

    state = VideoSavedState(videoPath: path, fileName: name, fileSize: sizeStr);
  }

  // 👉 2. Rename File on Device Storage (Pencil Icon ke liye)
  Future<bool> renameFile(String newName) async {
    try {
      if (newName.trim().isEmpty) return false;
      final file = File(state.videoPath);
      if (!await file.exists()) return false;

      final dir = file.parent.path;
      final ext = state.videoPath.split('.').last;

      // Agar user ne extension na likhi ho toh automatically add karein
      final cleanName = newName.endsWith('.$ext')
          ? newName.trim()
          : '${newName.trim()}.$ext';
      final newPath = '$dir/$cleanName';

      final renamedFile = await file.rename(newPath);

      state = state.copyWith(
        videoPath: renamedFile.path,
        fileName: cleanName,
        message: 'File renamed successfully!',
      );
      return true;
    } catch (e) {
      state = state.copyWith(message: 'Rename failed: $e');
      return false;
    }
  }

  // 3. Download Video to Device Storage (Downloads Folder)
  Future<void> downloadToDevice() async {
    try {
      final file = File(state.videoPath);
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
        state = state.copyWith(message: 'Video saved to Downloads folder!');
      } else {
        state = state.copyWith(message: 'Saved: ${state.videoPath}');
      }
    } catch (e) {
      state = state.copyWith(message: 'Download error: $e');
    }
  }
}

// ================= PROVIDER =================
final videoSavedViewModelProvider =
    StateNotifierProvider<VideoSavedViewModel, VideoSavedState>((ref) {
      return VideoSavedViewModel();
    });
