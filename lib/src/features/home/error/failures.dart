class AppFailure {
  final String message;
  final dynamic originalError;

  const AppFailure(this.message, [this.originalError]);

  @override
  String toString() => message;
}

class FilePickFailure extends AppFailure {
  const FilePickFailure(super.message, [super.originalError]);
}

class ConversionFailure extends AppFailure {
  const ConversionFailure(super.message, [super.originalError]);
}

class StorageFailure extends AppFailure {
  const StorageFailure(super.message, [super.originalError]);
}
