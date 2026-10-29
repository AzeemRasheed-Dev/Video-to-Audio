import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/src/features/home/error/failures.dart';
import 'package:my_app/src/features/home/model/conversion_state.dart';
import 'package:my_app/src/features/home/services/audio_converter_service.dart';
import 'package:my_app/src/features/home/services/file_picker_service.dart';
import 'package:my_app/src/features/home/services/storage_service.dart';

class ConverterViewModel extends StateNotifier<ConversionState> {
  final FilePickerService _filePickerService;
  final AudioConverterService _audioConverterService;
  final StorageService _storageService;

  ConverterViewModel({
    required FilePickerService filePickerService,
    required AudioConverterService audioConverterService,
    required StorageService storageService,
  }) : _filePickerService = filePickerService,
       _audioConverterService = audioConverterService,
       _storageService = storageService,
       super(ConversionState.initial());

  // 1. Video pick karna
  Future<void> pickVideo() async {
    try {
      state = state.copyWith(
        status: ConversionStatus.picking,
        clearError: true,
      );
      final picked = await _filePickerService.pickVideoFile();

      if (picked == null) {
        state = state.copyWith(
          status: state.videoPath != null
              ? ConversionStatus.picked
              : ConversionStatus.initial,
        );
        return;
      }

      state = state.copyWith(
        status: ConversionStatus.picked,
        videoPath: picked.path,
        videoName: picked.name,
        videoSizeBytes: picked.sizeBytes,
        audioPath: null,
        progress: 0.0,
      );
    } catch (e) {
      final msg = e is AppFailure ? e.message : e.toString();
      state = state.copyWith(status: ConversionStatus.error, errorMessage: msg);
    }
  }

  // 2. Format select karna (aac, mp3, m4a, wav)
  void setFormat(String format) {
    state = state.copyWith(selectedFormat: format);
  }

  // 3. Bitrate select karna (128k, 192k, 256k, 320k)
  void setBitrate(String bitrate) {
    state = state.copyWith(selectedBitrate: bitrate);
  }

  // 4. Video load hone par total duration set karna
  void setVideoDuration(double durationSec) {
    state = state.copyWith(
      videoDurationSec: durationSec,
      cutStartSec: 0.0,
      cutEndSec: durationSec,
    );
  }

  // 5. Video Cut / Trim Range update karna
  void setCutRange(double start, double end) {
    state = state.copyWith(cutStartSec: start, cutEndSec: end);
  }

  // 6. Video to Audio convert karna (with Format, Bitrate & Cut)
  Future<bool> convertVideo() async {
    final videoPath = state.videoPath;
    final videoName = state.videoName ?? 'audio';

    if (videoPath == null) {
      state = state.copyWith(
        status: ConversionStatus.error,
        errorMessage: 'Pehle koi video select karein!',
      );
      return false;
    }

    try {
      state = state.copyWith(
        status: ConversionStatus.converting,
        progress: 0.15,
        clearError: true,
      );

      // 👉 QA Bug 13 Fix: Selected format agar aac hai to exact .aac extension hi use ho, m4a nahi!
      final ext = state.selectedFormat.toLowerCase();

      final tempPath = await _storageService.createTempAudioPath(
        originalVideoName: videoName,
        format: ext,
      );

      // 👉 QA Bug 11 Fix: Conversion ke waqt proper loading feedback
      final startTime = DateTime.now();

      final result = await _audioConverterService.convertVideoToAudio(
        inputVideoPath: videoPath,
        outputAudioPath: tempPath,
        format: state.selectedFormat,
        bitrate: state.selectedBitrate,
        cutStartSec: state.cutStartSec,
        cutEndSec: state.cutEndSec,
        onProgress: (p) => state = state.copyWith(progress: p),
      );

      // Agar fast conversion ho gayi ho, tou kam az kam 1.2s tak loading indicator smoothly dikhe
      final elapsed = DateTime.now().difference(startTime).inMilliseconds;
      if (elapsed < 1200) {
        await Future.delayed(Duration(milliseconds: 1200 - elapsed));
      }

      state = state.copyWith(
        status: ConversionStatus.success,
        audioPath: result,
        progress: 1.0,
      );
      return true;
    } catch (e) {
      final msg = e is AppFailure ? e.message : e.toString();
      state = state.copyWith(status: ConversionStatus.error, errorMessage: msg);
      return false;
    }
  }

  // 👉 QA Bug 12 Fix: Result screen se wapis aane par loading screen stuck na rahe
  void resetConversionStatus() {
    if (state.status == ConversionStatus.success ||
        state.status == ConversionStatus.converting) {
      state = state.copyWith(status: ConversionStatus.picked, progress: 0.0);
    }
  }

  // 7. Audio file ko Downloads mein save karna
  Future<String?> saveAudioToDownloads() async {
    final audioPath = state.audioPath;
    final videoName = state.videoName ?? 'audio';

    if (audioPath == null) return null;

    try {
      final baseName = videoName.contains('.')
          ? videoName.substring(0, videoName.lastIndexOf('.'))
          : videoName;

      // 👉 QA Bug 13 Fix: Downloads me bhi exact .aac extension save hogi
      final ext = state.selectedFormat.toLowerCase();

      final savedPath = await _storageService.saveToDownloadsDirectory(
        sourceAudioPath: audioPath,
        targetFileName: '$baseName.$ext',
      );
      return savedPath;
    } catch (e) {
      final msg = e is AppFailure ? e.message : e.toString();
      state = state.copyWith(errorMessage: msg);
      return null;
    }
  }

  // Set Ringtone
  Future<bool> setRingtone() async {
    if (state.audioPath != null) {
      return await _storageService.setAudioAsRingtone(state.audioPath!);
    }
    return false;
  }

  // 8. Native Share Sheet
  Future<void> shareAudio() async {
    if (state.audioPath != null) {
      await _storageService.shareAudioFile(state.audioPath!);
    }
  }

  // 9. Audio play karna
  Future<void> openAudio() async {
    if (state.audioPath != null) {
      await _storageService.openAudioFile(state.audioPath!);
    }
  }

  // 10. Reset
  void reset() => state = ConversionState.initial();
}
