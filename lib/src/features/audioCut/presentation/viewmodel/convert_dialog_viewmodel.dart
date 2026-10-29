import 'dart:io';

import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

// ================= STATE =================
class ConvertDialogState {
  final String fileName;
  final String selectedFormat;
  final String selectedBitrate;
  final bool isConverting;
  final String? errorMessage;

  const ConvertDialogState({
    this.fileName = '',
    this.selectedFormat = 'AAC (ORIGINAL)',
    this.selectedBitrate = 'copy(62kb/s)',
    this.isConverting = false,
    this.errorMessage,
  });

  ConvertDialogState copyWith({
    String? fileName,
    String? selectedFormat,
    String? selectedBitrate,
    bool? isConverting,
    String? errorMessage,
  }) {
    return ConvertDialogState(
      fileName: fileName ?? this.fileName,
      selectedFormat: selectedFormat ?? this.selectedFormat,
      selectedBitrate: selectedBitrate ?? this.selectedBitrate,
      isConverting: isConverting ?? this.isConverting,
      errorMessage: errorMessage,
    );
  }
}

// ================= VIEWMODEL =================
class ConvertDialogViewModel extends StateNotifier<ConvertDialogState> {
  ConvertDialogViewModel() : super(const ConvertDialogState());

  // Dialog open hone par default naam set karein
  void initDialog(String originalAudioName) {
    final baseName = originalAudioName.split('.').first;
    final defaultName =
        'audioCutter_${baseName}_${DateTime.now().millisecondsSinceEpoch % 100000}';
    state = ConvertDialogState(fileName: defaultName);
  }

  void setFileName(String name) => state = state.copyWith(fileName: name);
  void setFormat(String format) =>
      state = state.copyWith(selectedFormat: format);
  void setBitrate(String bitrate) =>
      state = state.copyWith(selectedBitrate: bitrate);

  // FFmpeg se audio cut, speed change aur save karna
  Future<String?> convertAndCut({
    required String audioPath,
    required double startSec,
    required double endSec,
    double speed = 1.0, // 👈 Playback speed parameter
  }) async {
    state = state.copyWith(isConverting: true, errorMessage: null);

    try {
      final tempDir = await getApplicationDocumentsDirectory();
      final outDir = Directory('${tempDir.path}/CutAudios');
      if (!await outDir.exists()) {
        await outDir.create(recursive: true);
      }

      // Extension decide karna
      String ext = 'mp3';
      if (state.selectedFormat.contains('ORIGINAL')) {
        ext = audioPath.split('.').last;
      } else if (state.selectedFormat.contains('AAC')) {
        ext = 'aac';
      } else if (state.selectedFormat.contains('M4A')) {
        ext = 'm4a';
      } else if (state.selectedFormat.contains('WAV')) {
        ext = 'wav';
      }

      final outName = state.fileName.isNotEmpty
          ? state.fileName
          : 'cut_${DateTime.now().millisecondsSinceEpoch}';

      final outPath = '${outDir.path}/$outName.$ext';
      final duration = endSec - startSec;

      // Bitrate arguments
      String bitrateArg = '';
      if (state.selectedBitrate.contains('32'))
        bitrateArg = '-b:a 32k';
      else if (state.selectedBitrate.contains('64'))
        bitrateArg = '-b:a 64k';
      else if (state.selectedBitrate.contains('96'))
        bitrateArg = '-b:a 96k';
      else if (state.selectedBitrate.contains('128'))
        bitrateArg = '-b:a 128k';
      else if (state.selectedBitrate.contains('192'))
        bitrateArg = '-b:a 192k';
      else if (state.selectedBitrate.contains('256'))
        bitrateArg = '-b:a 256k';
      else if (state.selectedBitrate.contains('320'))
        bitrateArg = '-b:a 320k';

      String cmd = '';

      // Agar speed 1.0 nahi hai (0.5x, 1.5x, 2.0x), toh '-filter:a "atempo=$speed"' lagana lazmi hai
      if (speed != 1.0) {
        final effectiveBitrate = bitrateArg.isNotEmpty
            ? bitrateArg
            : '-b:a 192k';
        String codecArg = '';
        final lowerExt = ext.toLowerCase();

        if (lowerExt == 'mp3') {
          codecArg = '-c:a libmp3lame $effectiveBitrate';
        } else if (lowerExt == 'aac' || lowerExt == 'm4a') {
          codecArg = '-c:a aac $effectiveBitrate';
        } else if (lowerExt == 'wav') {
          codecArg = '-c:a pcm_s16le';
        } else {
          codecArg = effectiveBitrate;
        }

        cmd =
            '-y -ss ${startSec.toStringAsFixed(2)} -t ${duration.toStringAsFixed(2)} -i "$audioPath" -filter:a "atempo=$speed" $codecArg "$outPath"';
      } else {
        // Normal 1.0x speed
        if (state.selectedFormat.contains('ORIGINAL') &&
            state.selectedBitrate.contains('copy')) {
          cmd =
              '-y -ss ${startSec.toStringAsFixed(2)} -t ${duration.toStringAsFixed(2)} -i "$audioPath" -c copy "$outPath"';
        } else {
          cmd =
              '-y -ss ${startSec.toStringAsFixed(2)} -t ${duration.toStringAsFixed(2)} -i "$audioPath" $bitrateArg "$outPath"';
        }
      }

      final session = await FFmpegKit.execute(cmd);
      final returnCode = await session.getReturnCode();

      state = state.copyWith(isConverting: false);

      if (ReturnCode.isSuccess(returnCode)) {
        return outPath;
      } else {
        state = state.copyWith(errorMessage: 'Conversion failed');
        return null;
      }
    } catch (e) {
      state = state.copyWith(isConverting: false, errorMessage: e.toString());
      return null;
    }
  }
}

// ================= PROVIDER =================
final convertDialogViewModelProvider =
    StateNotifierProvider<ConvertDialogViewModel, ConvertDialogState>((ref) {
      return ConvertDialogViewModel();
    });
