import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/src/core/theme/app_tokens.dart';

import '../presentation/viewmodel/video_cut_viewmodel.dart';

class VideoTimePillsRow extends ConsumerWidget {
  const VideoTimePillsRow({super.key});

  String _formatPrecise(double sec) {
    if (sec < 0) sec = 0;
    final mins = sec.toInt() ~/ 60;
    final remainder = sec - (mins * 60);
    final m = mins.toString().padLeft(2, '0');
    final s = remainder.toStringAsFixed(1).padLeft(4, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(videoCutViewModelProvider);
    final vm = ref.read(videoCutViewModelProvider.notifier);
    final isDark = context.isDark;

    final textColor = AppTokens.text(isDark);
    final border = AppTokens.border(isDark);
    final pillBg = isDark ? const Color(0xFF1E2824) : const Color(0xFFEBF2EE);
    final duration = (state.endSec - state.startSec).clamp(
      0.0,
      double.infinity,
    );

    return Column(
      children: [
        // Start & End Pills Row
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Start',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _buildPill(
                    _formatPrecise(state.startSec),
                    pillBg,
                    border,
                    textColor,
                    () => vm.adjustStart(-0.1),
                    () => vm.adjustStart(0.1),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'End',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _buildPill(
                    _formatPrecise(state.endSec),
                    pillBg,
                    border,
                    textColor,
                    () => vm.adjustEnd(-0.1),
                    () => vm.adjustEnd(0.1),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),
        Divider(color: border),

        // Selected duration Row
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Selected duration',
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                _formatPrecise(duration),
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        Divider(color: border),
      ],
    );
  }

  Widget _buildPill(
    String time,
    Color bg,
    Color border,
    Color textColor,
    VoidCallback onMinus,
    VoidCallback onPlus,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onMinus,
            child: Icon(Icons.remove, color: textColor, size: 18),
          ),
          Text(
            time,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onPlus,
            child: Icon(Icons.add, color: textColor, size: 18),
          ),
        ],
      ),
    );
  }
}
