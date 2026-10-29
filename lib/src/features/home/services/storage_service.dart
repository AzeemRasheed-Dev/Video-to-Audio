import 'dart:io';
import 'dart:ui';

import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ringtone_set_plus/ringtone_set_plus.dart';
import 'package:share_plus/share_plus.dart';

import '../error/failures.dart';

class StorageService {
  /// 👉 QA Bug 17 Fix: Audio ab seedha ConvertedAudios folder me create hogi taake Output screen par show ho!
  Future<String> createTempAudioPath({
    required String originalVideoName,
    String format = 'm4a',
  }) async {
    try {
      final Directory docDir = await getApplicationDocumentsDirectory();
      final Directory outDir = Directory('${docDir.path}/ConvertedAudios');
      if (!await outDir.exists()) {
        await outDir.create(recursive: true);
      }

      final String baseName = originalVideoName.contains('.')
          ? originalVideoName.substring(0, originalVideoName.lastIndexOf('.'))
          : originalVideoName;

      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final cleanFormat = format.toLowerCase().replaceAll('.', '');
      return '${outDir.path}${Platform.pathSeparator}${baseName}_$timestamp.$cleanFormat';
    } catch (e) {
      throw StorageFailure('Output path generate nahi ho saka: $e', e);
    }
  }

  /// Downloads ya Device storage mein save karega
  Future<String> saveToDownloadsDirectory({
    required String sourceAudioPath,
    required String targetFileName,
  }) async {
    try {
      Directory? targetDir;

      if (Platform.isAndroid) {
        final publicDownload = Directory('/storage/emulated/0/Download');
        if (await publicDownload.exists()) {
          targetDir = publicDownload;
        } else {
          targetDir = await getExternalStorageDirectory();
        }
      } else {
        targetDir =
            await getDownloadsDirectory() ??
            await getApplicationDocumentsDirectory();
      }

      if (targetDir == null) {
        throw const StorageFailure('Storage directory nahi mil saki');
      }

      final String destinationPath =
          '${targetDir.path}${Platform.pathSeparator}$targetFileName';

      final File sourceFile = File(sourceAudioPath);
      if (!await sourceFile.exists()) {
        throw const StorageFailure('Source audio file exist nahi karti');
      }

      final File savedFile = await sourceFile.copy(destinationPath);
      return savedFile.path;
    } catch (e) {
      try {
        final fallbackDir = await getApplicationDocumentsDirectory();
        final String fallbackPath =
            '${fallbackDir.path}${Platform.pathSeparator}$targetFileName';
        final File savedFile = await File(sourceAudioPath).copy(fallbackPath);
        return savedFile.path;
      } catch (err) {
        throw StorageFailure('Save karne mein error: $e', e);
      }
    }
  }

  /// Converted audio open/play karna
  Future<void> openAudioFile(String filePath) async {
    try {
      await OpenFile.open(filePath);
    } catch (e) {
      throw StorageFailure('Audio open nahi ho saki: $e', e);
    }
  }

  /// Official Android Save/Share sheet open karega
  Future<void> shareAudioFile(String filePath) async {
    try {
      final file = XFile(filePath);
      await Share.shareXFiles(
        [file],
        text: 'Converted Audio',
        sharePositionOrigin: const Rect.fromLTWH(0, 0, 100, 100),
      );
    } catch (e) {
      print('Share error: $e');
    }
  }

  /// Converted Audio ko Phone ki Ringtone banana
  Future<bool> setAudioAsRingtone(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return false;

      final bool success = await RingtoneSet.setRingtoneFromFile(file);
      return success;
    } catch (e) {
      print('Ringtone error: $e');
      return false;
    }
  }
}
