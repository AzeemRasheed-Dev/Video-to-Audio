import 'package:flutter/material.dart';
import 'package:my_app/src/core/theme/app_tokens.dart';

class AudioWaveformCutter extends StatelessWidget {
  final double totalDuration;
  final double startSec;
  final double endSec;
  final double currentPosSec;
  final ValueChanged<double> onStartChanged;
  final ValueChanged<double> onEndChanged;
  final ValueChanged<double> onSeek;
  final ValueChanged<double> onAdjustStart;
  final ValueChanged<double> onAdjustEnd;

  const AudioWaveformCutter({
    super.key,
    required this.totalDuration,
    required this.startSec,
    required this.endSec,
    required this.currentPosSec,
    required this.onStartChanged,
    required this.onEndChanged,
    required this.onSeek,
    required this.onAdjustStart,
    required this.onAdjustEnd,
  });

  String _format(double sec) {
    if (sec < 0) sec = 0;
    final int ms = (sec * 1000).toInt();
    final int m = ms ~/ 60000;
    final int s = (ms % 60000) ~/ 1000;
    final int tenth = (ms % 1000) ~/ 100;
    final String two = s.toString().padLeft(2, '0');
    return "${m.toString().padLeft(2, '0')}:$two.$tenth";
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final cardBg = AppTokens.card(isDark);
    final accent = AppTokens.accent(isDark);
    final btnText = AppTokens.btnText(isDark);
    final textColor = AppTokens.text(isDark);
    final textSecondary = AppTokens.textSecondary(isDark);
    final border = AppTokens.border(isDark);

    final trimmedDur = (endSec - startSec).clamp(0.0, totalDuration);

    // 👉 QA Bug 15 Fix: Proportional compact waveform bars
    final waveHeights = [
      8.0,
      15.0,
      30.0,
      45.0,
      22.0,
      55.0,
      34.0,
      18.0,
      42.0,
      12.0,
      21.0,
      36.0,
      58.0,
      26.0,
      50.0,
      38.0,
      18.0,
      48.0,
      14.0,
      32.0,
      10.0,
      24.0,
      40.0,
      54.0,
      28.0,
      58.0,
      35.0,
      16.0,
      44.0,
      10.0,
      20.0,
      38.0,
      56.0,
      28.0,
      52.0,
      40.0,
      18.0,
      46.0,
      12.0,
      32.0,
    ];

    return Column(
      children: [
        // ================= WAVEFORM CONTAINER (QA Bug 15: Height 190 -> 130) =================
        Container(
          height: 130, // 👈 Height reduced from 190 to 130
          width: double.infinity,
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border, width: 1.0),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              const safePadding = 22.0;
              final trackWidth = constraints.maxWidth - (safePadding * 2);
              final dur = totalDuration > 0 ? totalDuration : 1.0;

              final startX = safePadding + (startSec / dur) * trackWidth;
              final endX = safePadding + (endSec / dur) * trackWidth;
              final curX = safePadding + (currentPosSec / dur) * trackWidth;

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // 1. Selection Shaded Background (Active Range)
                  Positioned(
                    left: startX,
                    width: (endX - startX).clamp(0.0, trackWidth),
                    top: 6,
                    bottom: 20,
                    child: Container(
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.10),
                        border: Border(
                          top: BorderSide(
                            color: accent.withValues(alpha: 0.5),
                            width: 1.5,
                          ),
                          bottom: BorderSide(
                            color: accent.withValues(alpha: 0.5),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 2. Waveform Bars (Active = Accent, Inactive = Dimmed)
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: safePadding,
                        vertical: 18,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: List.generate(waveHeights.length, (i) {
                          final barX =
                              safePadding +
                              (i / (waveHeights.length - 1)) * trackWidth;
                          final isInside = barX >= startX && barX <= endX;
                          return Container(
                            width: 2.4,
                            height: waveHeights[i],
                            decoration: BoxDecoration(
                              color: isInside
                                  ? accent
                                  : textSecondary.withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),

                  // 3. Playhead Cursor + Timestamp
                  Positioned(
                    left: curX - 1,
                    top: 6,
                    bottom: 20,
                    child: Container(
                      width: 2,
                      color: textColor,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: textColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: (curX - 25).clamp(
                      safePadding,
                      constraints.maxWidth - 55,
                    ),
                    bottom: 2,
                    child: Text(
                      _format(currentPosSec),
                      style: TextStyle(
                        color: textColor,
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // 4. Left Vertical Accent Line
                  Positioned(
                    left: startX,
                    top: 6,
                    bottom: 20,
                    child: Container(width: 2.2, color: accent),
                  ),

                  // 5. Right Vertical Accent Line
                  Positioned(
                    left: endX,
                    top: 6,
                    bottom: 20,
                    child: Container(width: 2.2, color: accent),
                  ),

                  // 6. Left Draggable Handle (<) - Touch Area (40x40)
                  Positioned(
                    left: startX - 20,
                    top: 8,
                    width: 40,
                    height: 40,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onHorizontalDragUpdate: (d) {
                        final deltaSec = (d.delta.dx / trackWidth) * dur;
                        onStartChanged(startSec + deltaSec);
                      },
                      onHorizontalDragEnd: (_) => onSeek(startSec),
                      child: Center(
                        child: _buildHandle(
                          Icons.chevron_left,
                          accent: accent,
                          iconColor: btnText,
                        ),
                      ),
                    ),
                  ),

                  // 7. Right Draggable Handle (>) - Touch Area (40x40)
                  Positioned(
                    left: endX - 20,
                    bottom: 14,
                    width: 40,
                    height: 40,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onHorizontalDragUpdate: (d) {
                        final deltaSec = (d.delta.dx / trackWidth) * dur;
                        onEndChanged(endSec + deltaSec);
                      },
                      onHorizontalDragEnd: (_) => onSeek(endSec),
                      child: Center(
                        child: _buildHandle(
                          Icons.chevron_right,
                          accent: accent,
                          iconColor: btnText,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),

        const SizedBox(height: 14),

        // ================= TIME ADJUSTMENT ROW =================
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildTimePill(
              timeStr: _format(startSec),
              onMinus: () => onAdjustStart(-0.1),
              onPlus: () => onAdjustStart(0.1),
              cardBg: cardBg,
              border: border,
              textColor: textColor,
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'DURATION',
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _format(trimmedDur),
                  style: TextStyle(
                    color: accent,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            _buildTimePill(
              timeStr: _format(endSec),
              onMinus: () => onAdjustEnd(-0.1),
              onPlus: () => onAdjustEnd(0.1),
              cardBg: cardBg,
              border: border,
              textColor: textColor,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHandle(
    IconData icon, {
    required Color accent,
    required Color iconColor,
  }) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: accent,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(child: Icon(icon, color: iconColor, size: 18)),
    );
  }

  Widget _buildTimePill({
    required String timeStr,
    required VoidCallback onMinus,
    required VoidCallback onPlus,
    required Color cardBg,
    required Color border,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: onMinus,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Icon(Icons.remove, color: textColor, size: 15),
            ),
          ),
          Text(
            timeStr,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 11.5,
            ),
          ),
          InkWell(
            onTap: onPlus,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Icon(Icons.add, color: textColor, size: 15),
            ),
          ),
        ],
      ),
    );
  }
}
