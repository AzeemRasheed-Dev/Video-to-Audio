import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/src/app/router/app_routes.dart';
import 'package:my_app/src/core/theme/app_tokens.dart'; // 👈 Theme Tokens
import 'package:my_app/src/features/videoCut/widgets/video_time_pills_row.dart';
import 'package:my_app/src/features/videoCut/widgets/widgets/video_bottom_actions.dart';
import 'package:my_app/src/features/videoCut/widgets/widgets/video_range_trimmer.dart';

import '../../widgets/video_preview_player.dart';
import '../viewmodel/video_cut_viewmodel.dart';

class VideoCutScreen2 extends ConsumerWidget {
  const VideoCutScreen2({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(videoCutViewModelProvider);
    final vm = ref.read(videoCutViewModelProvider.notifier);
    final isDark = context.isDark; // 👈 Dark Mode Check

    final bg = AppTokens.bg(isDark);
    final textColor = AppTokens.text(isDark);
    final accent = AppTokens.accent(isDark);
    final isReady = state.isInitialized && !state.isCutting;

    return Scaffold(
      backgroundColor: bg, // 👈 Dynamic Dark/Light Background
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Trim clip',
          style: TextStyle(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: isReady
                ? () async {
                    final outPath = await vm.cutVideo();
                    if (context.mounted && outPath != null) {
                      context.push(AppRoutes.videoSaved, extra: outPath);
                    }
                  }
                : null,
            child: Text(
              'Done',
              style: TextStyle(
                color: isReady ? accent : Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: !state.isInitialized
          ? Center(child: CircularProgressIndicator(color: accent))
          : const SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  VideoPreviewPlayer(),
                  SizedBox(height: 16),
                  VideoRangeTrimmer(),
                  SizedBox(height: 20),
                  VideoTimePillsRow(),
                  SizedBox(height: 12),
                  VideoBottomActions(),
                  SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
