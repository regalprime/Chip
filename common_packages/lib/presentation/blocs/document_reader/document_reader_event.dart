part of 'document_reader_bloc.dart';

sealed class DocumentReaderEvent extends Equatable {
  const DocumentReaderEvent();

  @override
  List<Object?> get props => [];
}

class LoadDocumentsEvent extends DocumentReaderEvent {
  const LoadDocumentsEvent();
}

class ImportDocumentEvent extends DocumentReaderEvent {
  const ImportDocumentEvent();
}

class RemoveDocumentEvent extends DocumentReaderEvent {
  const RemoveDocumentEvent({required this.documentId, required this.fileUrl});

  final String documentId;
  final String fileUrl;

  @override
  List<Object?> get props => [documentId, fileUrl];
}

class UpdateReaderSettingsEvent extends DocumentReaderEvent {
  const UpdateReaderSettingsEvent({
    this.fontSize,
    this.lineHeight,
    this.readerTheme,
  });

  final double? fontSize;
  final double? lineHeight;
  final ReaderTheme? readerTheme;

  @override
  List<Object?> get props => [fontSize, lineHeight, readerTheme];
}

class LoadReaderSettingsEvent extends DocumentReaderEvent {
  const LoadReaderSettingsEvent();
}

class SaveDocReadingStateEvent extends DocumentReaderEvent {
  const SaveDocReadingStateEvent({
    required this.documentId,
    this.currentPage,
    this.isTextMode,
    this.textScrollOffset,
  });

  final String documentId;
  final int? currentPage;
  final bool? isTextMode;
  final double? textScrollOffset;

  @override
  List<Object?> get props => [documentId, currentPage, isTextMode, textScrollOffset];
}
