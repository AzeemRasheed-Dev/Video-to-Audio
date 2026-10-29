class OutputFileItem {
  final String path;
  final String name;
  final int sizeInBytes;
  final DateTime modifiedDate;
  final bool isVideo;

  OutputFileItem({
    required this.path,
    required this.name,
    required this.sizeInBytes,
    required this.modifiedDate,
    required this.isVideo,
  });

  String get formattedSize {
    final mb = sizeInBytes / (1024 * 1024);
    if (mb >= 1) return '${mb.toStringAsFixed(1)} MB';
    final kb = sizeInBytes / 1024;
    return '${kb.toStringAsFixed(1)} KB';
  }

  String get formattedDate {
    return '${modifiedDate.day}/${modifiedDate.month}/${modifiedDate.year}';
  }
}