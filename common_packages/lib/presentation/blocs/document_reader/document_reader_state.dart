part of 'document_reader_bloc.dart';

enum DocumentReaderStatus { initial, loading, importing, loaded, error }

enum ReaderTheme { light, sepia, dark }

class ReaderSettings extends Equatable {
  const ReaderSettings({
    this.fontSize = 22,
    this.lineHeight = 1.6,
    this.readerTheme = ReaderTheme.light,
  });

  final double fontSize;
  final double lineHeight;
  final ReaderTheme readerTheme;

  ReaderSettings copyWith({
    double? fontSize,
    double? lineHeight,
    ReaderTheme? readerTheme,
  }) {
    return ReaderSettings(
      fontSize: fontSize ?? this.fontSize,
      lineHeight: lineHeight ?? this.lineHeight,
      readerTheme: readerTheme ?? this.readerTheme,
    );
  }

  @override
  List<Object?> get props => [fontSize, lineHeight, readerTheme];
}

class DocumentReaderState extends Equatable {
  const DocumentReaderState({
    this.status = DocumentReaderStatus.initial,
    this.documents = const [],
    this.settings = const ReaderSettings(),
    this.errorMessage,
  });

  final DocumentReaderStatus status;
  final List<DocumentEntity> documents;
  final ReaderSettings settings;
  final String? errorMessage;

  DocumentReaderState copyWith({
    DocumentReaderStatus? status,
    List<DocumentEntity>? documents,
    ReaderSettings? settings,
    String? errorMessage,
  }) {
    return DocumentReaderState(
      status: status ?? this.status,
      documents: documents ?? this.documents,
      settings: settings ?? this.settings,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, documents, settings, errorMessage];
}
