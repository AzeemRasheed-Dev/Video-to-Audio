import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/src/features/home/model/conversion_state.dart';
import 'package:my_app/src/features/home/services/audio_converter_service.dart';
import 'package:my_app/src/features/home/services/file_picker_service.dart';
import 'package:my_app/src/features/home/services/storage_service.dart';

import 'converter_viewmodel.dart';

// 1. Service Providers (Dependency Injection)
final filePickerServiceProvider = Provider<FilePickerService>((ref) {
  return FilePickerService();
});

final audioConverterServiceProvider = Provider<AudioConverterService>((ref) {
  return AudioConverterService();
});

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

// 2. ViewModel Provider (MVVM Standard)
// - State dekhne ke liye: ref.watch(converterViewModelProvider)
// - Functions chalane ke liye: ref.read(converterViewModelProvider.notifier)
final converterViewModelProvider =
    StateNotifierProvider<ConverterViewModel, ConversionState>((ref) {
  return ConverterViewModel(
    filePickerService: ref.watch(filePickerServiceProvider),
    audioConverterService: ref.watch(audioConverterServiceProvider),
    storageService: ref.watch(storageServiceProvider),
  );
});