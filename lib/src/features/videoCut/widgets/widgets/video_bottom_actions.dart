import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/src/app/router/app_routes.dart';
import 'package:my_app/src/core/theme/app_tokens.dart';

import '../../presentation/viewmodel/video_cut_viewmodel.dart';

class VideoBottomActions extends ConsumerWidget {
  const VideoBottomActions({super.key});

  Future<void> _handleApplyTrim(BuildContext context, WidgetRef ref) async {
    final vm = ref.read(videoCutViewModelProvider.notifier);
    final outPath = await vm.cutVideo();

    if (!context.mounted) return;

    if (outPath != null) {
      context.push(AppRoutes.videoSaved, extra: outPath);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Video trimming failed!'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(videoCutViewModelProvider);
    final isDark = context.isDark;

    final cardBg = isDark ? const Color(0xFF1E2824) : Colors.white;
    final textColor = AppTokens.text(isDark);
    final textSecondary = AppTokens.textSecondary(isDark);
    final border = AppTokens.border(isDark);
    final accent = const Color(0xFF266653);
    final isReady = state.isInitialized && !state.isCutting;

    return Column(
      children: [
        // ================= 1. SPONSOR CARD (Themed) =================
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.spa_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ad • Sample sponsor',
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      'Sponsored content',
                      style: TextStyle(color: textSecondary, fontSize: 11),
                    ),
                  ],
                ),
              ),
              // "Learn more" Button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: border),
                    ),
                    child: Text(
                      'Learn more',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ================= 2. CANCEL & APPLY TRIM BUTTONS =================
        Row(
          children: [
            // "Cancel" Button
            Expanded(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => context.pop(),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: accent, width: 1.5),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: accent,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // "Apply trim" Button
            Expanded(
              child: Material(
                color: isReady
                    ? accent
                    : (isDark ? Colors.grey.shade800 : Colors.grey.shade400),
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: isReady ? () => _handleApplyTrim(context, ref) : null,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 48,
                    alignment: Alignment.center,
                    child: state.isCutting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Apply trim',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
