import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../error/failures.dart';

class PickedVideoData {
  final String path;
  final String name;
  final int sizeBytes;

  const PickedVideoData({
    required this.path,
    required this.name,
    required this.sizeBytes,
  });
}

class FilePickerService {
  final ImagePicker _imagePicker = ImagePicker();

  /// ✅ 1. Mobile ki NATIVE GALLERY kholay ga aur SIRF VIDEOS select hongi
  Future<PickedVideoData?> pickVideoFile() async {
    try {
      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
      );

      if (video == null) {
        return null; // User ne cancel kar diya
      }

      final String path = video.path;
      final ioFile = File(path);

      if (!await ioFile.exists()) {
        throw const FilePickFailure('Selected video disk par mojood nahi hai');
      }

      final int sizeBytes = await ioFile.length();
      final String name = video.name.isNotEmpty
          ? video.name
          : path.split(Platform.pathSeparator).last;

      return PickedVideoData(path: path, name: name, sizeBytes: sizeBytes);
    } catch (e) {
      if (e is AppFailure) rethrow;
      throw FilePickFailure('Error picking video: $e', e);
    }
  }

  /// ✅ 2. Audio Cutter k liye SIRF AUDIOS allow karega (FilePicker)
  Future<PlatformFile?> pickAudioFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'm4a', 'wav', 'aac', 'flac', 'ogg', 'wma'],
        allowMultiple: false,
      );
      if (result != null && result.files.isNotEmpty) {
        return result.files.first;
      }
      return null;
    } catch (e) {
      debugPrint('Audio pick error: $e');
      return null;
    }
  }
}
