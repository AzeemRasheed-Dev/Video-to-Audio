import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/src/core/theme/app_tokens.dart';
import 'package:my_app/src/features/home/presntation/viewmodel/converter_providers.dart';
import 'package:my_app/src/features/home/presntation/viewmodel/result_viewmodel.dart';


class ResultActionsSection extends ConsumerWidget {
  const ResultActionsSection({super.key});

  void _toast(BuildContext context, String msg, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        backgroundColor: isSuccess ? const Color(0xFF10B981) : const Color(0xFFE5214E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final convState = ref.watch(converterViewModelProvider);
    final resultVM = ref.read(resultViewModelProvider.notifier);
    final isDark = context.isDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header (Figma Match)
        Text(
          'AUDIO ACTIONS',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: AppTokens.textSecondary(isDark),
          ),
        ),
        const SizedBox(height: 14),

        // 3 Action Buttons Row: [Share] [Download] [Set as]
        Row(
          children: [
            // 1. Share Action
            Expanded(
              child: _buildActionBtn(
                isDark: isDark,
                icon: Icons.ios_share_rounded,
                label: 'Share',
                onTap: () => resultVM.shareAudio(),
              ),
            ),
            const SizedBox(width: 12),

            // 2. Download Action
            Expanded(
              child: _buildActionBtn(
                isDark: isDark,
                icon: Icons.download_rounded,
                label: 'Download',
                onTap: () async {
                  final path = await resultVM.saveToDownloads(
                    convState.videoName,
                    convState.selectedFormat,
                  );
                  if (context.mounted) {
                    _toast(
                      context,
                      path != null ? 'Saved to Downloads successfully!' : 'Save failed!',
                      path != null,
                    );
                  }
                },
              ),
            ),
            const SizedBox(width: 12),

            // 3. Set as (Ringtone) Action
            Expanded(
              child: _buildActionBtn(
                isDark: isDark,
                icon: Icons.notifications_none_rounded,
                label: 'Set as',
                onTap: () async {
                  final ok = await resultVM.setRingtone();
                  if (context.mounted) {
                    _toast(
                      context,
                      ok ? 'Ringtone set successfully!' : 'Permission required: Allow Modify Settings.',
                      ok,
                    );
                  }
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Helper text below buttons
        Center(
          child: Text(
            'Actions apply to the selected file.',
            style: TextStyle(
              fontSize: 11,
              color: AppTokens.textSecondary(isDark).withOpacity(0.8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionBtn({
    required bool isDark,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTokens.card(isDark),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTokens.border(isDark)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppTokens.text(isDark), size: 24),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTokens.border(isDark), width: 1.0),
            ),
            child: InkWell(
              onTap: onTap,
              child: Text(
                label,
                style: TextStyle(
                  color: AppTokens.text(isDark),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}