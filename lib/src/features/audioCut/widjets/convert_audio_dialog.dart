import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/src/app/router/app_routes.dart';
import 'package:my_app/src/core/theme/app_tokens.dart';

import '../presentation/viewmodel/AudioCutViewModel.dart';
import '../presentation/viewmodel/convert_dialog_viewmodel.dart';

class ConvertAudioDialog extends ConsumerWidget {
  const ConvertAudioDialog({super.key});

  static const List<String> _formats = [
    'AAC (ORIGINAL)',
    'MP3',
    'AAC',
    'M4A',
    'WAV',
  ];

  static const List<String> _bitrates = [
    'copy(62kb/s)',
    '32 kbps (CBR)',
    '64 kbps (CBR)',
    '96 kbps (CBR)',
    '128 kbps (CBR)',
    '192 kbps (CBR)',
    '256 kbps (CBR)',
    '320 kbps (CBR)',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dialogState = ref.watch(convertDialogViewModelProvider);
    final dialogVm = ref.read(convertDialogViewModelProvider.notifier);
    final cutState = ref.read(audioCutViewModelProvider);

    final isDark = context.isDark;
    final cardBg = AppTokens.card(isDark);
    final bg = AppTokens.bg(isDark);
    final accent = AppTokens.accent(isDark);
    final btnText = isDark ? AppTokens.darkBtnText : AppTokens.lightBtnText;
    final textColor = AppTokens.text(isDark);
    final textSecondary = AppTokens.textSecondary(isDark);
    final border = AppTokens.border(isDark);

    return Dialog(
      backgroundColor: cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: border, width: 1.0),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Convert Audio',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: dialogState.isConverting
                      ? null
                      : () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: textSecondary, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // File Name Label
            Text(
              'File Name',
              style: TextStyle(
                color: textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            TextFormField(
              initialValue: dialogState.fileName,
              onChanged: dialogVm.setFileName,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: border, width: 1.2),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: accent, width: 2.0),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Format Dropdown
            Text(
              'Format',
              style: TextStyle(
                color: textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: bg,
                border: Border.all(color: border),
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: dialogState.selectedFormat,
                  isExpanded: true,
                  dropdownColor: cardBg,
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: textSecondary,
                  ),
                  items: _formats.map((fmt) {
                    return DropdownMenuItem<String>(
                      value: fmt,
                      child: Text(
                        fmt,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) dialogVm.setFormat(val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Bitrate Dropdown
            Text(
              'Bitrate',
              style: TextStyle(
                color: textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: bg,
                border: Border.all(color: border),
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: dialogState.selectedBitrate,
                  isExpanded: true,
                  dropdownColor: cardBg,
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: textSecondary,
                  ),
                  items: _bitrates.map((br) {
                    return DropdownMenuItem<String>(
                      value: br,
                      child: Text(
                        br,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) dialogVm.setBitrate(val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Buttons (CANCEL & CONVERT)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: dialogState.isConverting
                      ? null
                      : () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                  child: Text(
                    'CANCEL',
                    style: TextStyle(
                      color: textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: dialogState.isConverting
                      ? null
                      : () async {
                          if (cutState.audioPath == null) return;

                          final outPath = await dialogVm.convertAndCut(
                            audioPath: cutState.audioPath!,
                            startSec: cutState.startSec,
                            endSec: cutState.endSec,
                            speed: cutState.playbackSpeed,
                          );

                          if (!context.mounted) return;

                          if (outPath != null) {
                            Navigator.pop(context); // Dialog close

                            // AudioSavedScreen par navigate karein:
                            context.push(AppRoutes.audioSaved, extra: outPath);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  dialogState.errorMessage ??
                                      'Conversion failed!',
                                ),
                                backgroundColor: const Color(0xFFE5214E),
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 11,
                    ),
                  ),
                  child: dialogState.isConverting
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: btnText,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'CONVERT',
                          style: TextStyle(
                            color: btnText,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
