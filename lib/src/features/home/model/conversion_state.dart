enum ConversionStatus { initial, picking, picked, converting, success, error }

class ConversionState {
  final ConversionStatus status;
  final String? videoPath;
  final String? videoName;
  final int? videoSizeBytes;
  final String? audioPath;
  final double progress;
  final String? errorMessage;

  // 👉 Naye fields: Format, Bitrate, Cut, Duration
  final String selectedFormat; // 'aac', 'mp3', 'm4a', 'wav'
  final String selectedBitrate; // '128k', '192k', '256k', '320k'
  final double videoDurationSec;
  final double cutStartSec;
  final double cutEndSec;

  const ConversionState({
    this.status = ConversionStatus.initial,
    this.videoPath,
    this.videoName,
    this.videoSizeBytes,
    this.audioPath,
    this.progress = 0.0,
    this.errorMessage,
    this.selectedFormat = 'aac',
    this.selectedBitrate = '192k',
    this.videoDurationSec = 0.0,
    this.cutStartSec = 0.0,
    this.cutEndSec = 0.0,
  });

  factory ConversionState.initial() => const ConversionState();

  bool get isInitial => status == ConversionStatus.initial;
  bool get isPicking => status == ConversionStatus.picking;
  bool get isPicked => status == ConversionStatus.picked;
  bool get isConverting => status == ConversionStatus.converting;
  bool get isSuccess => status == ConversionStatus.success;
  bool get isError => status == ConversionStatus.error;

  String get formattedVideoSize {
    if (videoSizeBytes == null) return '';
    final mb = videoSizeBytes! / (1024 * 1024);
    return '${mb.toStringAsFixed(2)} MB';
  }

  ConversionState copyWith({
    ConversionStatus? status,
    String? videoPath,
    String? videoName,
    int? videoSizeBytes,
    String? audioPath,
    double? progress,
    String? errorMessage,
    bool clearError = false,
    String? selectedFormat,
    String? selectedBitrate,
    double? videoDurationSec,
    double? cutStartSec,
    double? cutEndSec,
  }) {
    return ConversionState(
      status: status ?? this.status,
      videoPath: videoPath ?? this.videoPath,
      videoName: videoName ?? this.videoName,
      videoSizeBytes: videoSizeBytes ?? this.videoSizeBytes,
      audioPath: audioPath ?? this.audioPath,
      progress: progress ?? this.progress,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      selectedFormat: selectedFormat ?? this.selectedFormat,
      selectedBitrate: selectedBitrate ?? this.selectedBitrate,
      videoDurationSec: videoDurationSec ?? this.videoDurationSec,
      cutStartSec: cutStartSec ?? this.cutStartSec,
      cutEndSec: cutEndSec ?? this.cutEndSec,
    );
  }
}
