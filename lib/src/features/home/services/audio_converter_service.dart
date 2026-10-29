import 'dart:io';

import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';

import '../error/failures.dart';

class AudioConverterService {
  Future<String> convertVideoToAudio({
    required String inputVideoPath,
    required String outputAudioPath,
    required String format,
    required String bitrate,
    double? cutStartSec,
    double? cutEndSec,
    Function(double progress)? onProgress,
  }) async {
    try {
      final inputFile = File(inputVideoPath);
      if (!await inputFile.exists()) {
        throw const ConversionFailure('Input video file mojood nahi hai');
      }

      final outputFile = File(outputAudioPath);
      if (await outputFile.exists()) {
        await outputFile.delete();
      }

      // 1. Cut timing argument
      String cutArgs = '';
      if (cutStartSec != null && cutEndSec != null && cutEndSec > cutStartSec) {
        cutArgs =
            '-ss ${cutStartSec.toStringAsFixed(2)} -to ${cutEndSec.toStringAsFixed(2)} ';
      }

      // 2. Format ke mutabiq sahi codec choose karein
      String codec = '-c:a aac';
      final fmt = format.toLowerCase();
      if (fmt == 'mp3') {
        codec = '-c:a libmp3lame';
      } else if (fmt == 'wav') {
        codec = '-c:a pcm_s16le';
      } else {
        codec = '-c:a aac';
      }

      // 3. Dynamic Command
      final String command =
          '-y $cutArgs-i "$inputVideoPath" -vn $codec -b:a $bitrate "$outputAudioPath"';

      onProgress?.call(0.2);

      final session = await FFmpegKit.execute(command);
      final ReturnCode? returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        onProgress?.call(1.0);
        return outputAudioPath;
      } else {
        // Fallback: Agar device par mp3lame na ho toh aac/m4a mein convert karein
        final fallbackOutput = outputAudioPath.replaceAll(
          RegExp(r'\.[a-zA-Z0-9]+$'),
          '.m4a',
        );
        final fallbackCmd =
            '-y $cutArgs-i "$inputVideoPath" -vn -c:a aac -b:a $bitrate "$fallbackOutput"';
        final fbSession = await FFmpegKit.execute(fallbackCmd);
        if (ReturnCode.isSuccess(await fbSession.getReturnCode())) {
          onProgress?.call(1.0);
          return fallbackOutput;
        }

        final failStackTrace = await session.getFailStackTrace();
        throw ConversionFailure(
          'FFmpeg failed with code: ${returnCode?.getValue()}. Details: ${failStackTrace ?? "Unknown"}',
        );
      }
    } catch (e) {
      if (e is AppFailure) rethrow;
      throw ConversionFailure('Conversion error: $e', e);
    }
  }
}
