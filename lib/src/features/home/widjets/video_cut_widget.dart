import 'package:flutter/material.dart';

class VideoCutWidget extends StatelessWidget {
  final double totalDurationSec;
  final double startSec;
  final double endSec;
  final Function(double start, double end) onRangeChanged;

  const VideoCutWidget({
    super.key,
    required this.totalDurationSec,
    required this.startSec,
    required this.endSec,
    required this.onRangeChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (totalDurationSec <= 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.content_cut, color: Color(0xFFE5214E), size: 18),
                  SizedBox(width: 6),
                  Text('Trim / Cut Video', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
              Text(
                '${startSec.toStringAsFixed(1)}s - ${endSec.toStringAsFixed(1)}s',
                style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFFE5214E)),
              ),
            ],
          ),
          RangeSlider(
            values: RangeValues(startSec, endSec > totalDurationSec ? totalDurationSec : endSec),
            min: 0.0,
            max: totalDurationSec > 0 ? totalDurationSec : 1.0,
            activeColor: const Color(0xFFE5214E),
            inactiveColor: Colors.grey.shade300,
            onChanged: (RangeValues values) {
              onRangeChanged(values.start, values.end);
            },
          ),
        ],
      ),
    );
  }
}