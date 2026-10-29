import 'package:flutter/material.dart';
import 'package:my_app/src/core/theme/app_tokens.dart';


class FormatBitrateWidget extends StatelessWidget {
  final String selectedFormat;
  final String selectedBitrate;
  final ValueChanged<String> onFormatChanged;
  final ValueChanged<String> onBitrateChanged;

  const FormatBitrateWidget({
    super.key,
    required this.selectedFormat,
    required this.selectedBitrate,
    required this.onFormatChanged,
    required this.onBitrateChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final formats = ['aac', 'mp3', 'm4a', 'wav'];
    final bitrates = ['128k', '192k', '256k', '320k'];

    final currentFormat = formats.contains(selectedFormat.toLowerCase())
        ? selectedFormat.toLowerCase()
        : formats.first;

    final currentBitrate = bitrates.contains(selectedBitrate.toLowerCase())
        ? selectedBitrate.toLowerCase()
        : '192k';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // ================= 1. FORMAT DROPDOWN CARD =================
            Expanded(
              child: _buildDropdownCard(
                context: context,
                isDark: isDark,
                label: 'Format',
                displayValue: currentFormat.toUpperCase(),
                items: formats,
                selectedValue: currentFormat,
                displayItem: (item) => item.toUpperCase(),
                onChanged: onFormatChanged,
              ),
            ),

            const SizedBox(width: 12),

            // ================= 2. BITRATE DROPDOWN CARD =================
            Expanded(
              child: _buildDropdownCard(
                context: context,
                isDark: isDark,
                label: 'Bitrate',
                displayValue: _formatBitrateLabel(currentBitrate),
                items: bitrates,
                selectedValue: currentBitrate,
                displayItem: (item) => _formatBitrateLabel(item),
                onChanged: onBitrateChanged,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Subtitle text (Figma Match)
        Text(
          'Choose the format and quality for your audio.',
          style: TextStyle(
            fontSize: 11,
            color: AppTokens.textSecondary(isDark),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownCard({
    required BuildContext context,
    required bool isDark,
    required String label,
    required String displayValue,
    required List<String> items,
    required String selectedValue,
    required String Function(String) displayItem,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTokens.card(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTokens.border(isDark), width: 1.0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: PopupMenuButton<String>(
        onSelected: onChanged,
        color: AppTokens.card(isDark),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        itemBuilder: (ctx) => items.map((item) {
          final isSelected = item == selectedValue;
          return PopupMenuItem<String>(
            value: item,
            child: Text(
              displayItem(item),
              style: TextStyle(
                color: isSelected ? AppTokens.accent(isDark) : AppTokens.text(isDark),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          );
        }).toList(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: AppTokens.textSecondary(isDark),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  displayValue,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppTokens.text(isDark),
                  ),
                ),
              ],
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppTokens.textSecondary(isDark),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  String _formatBitrateLabel(String b) {
    final clean = b.replaceAll('k', '');
    return '$clean kbps';
  }
}