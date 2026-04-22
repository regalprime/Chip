import 'dart:io';

import 'package:common_packages/domain/entities/document/document_entity.dart';
import 'package:common_packages/domain/repositories/remote_data_source.dart';
import 'package:common_packages/util/app_preferences.dart';
import 'package:docx_to_text/docx_to_text.dart';
import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

part 'document_reader_event.dart';
part 'document_reader_state.dart';

class DocumentReaderBloc extends Bloc<DocumentReaderEvent, DocumentReaderState> {
  DocumentReaderBloc({
    required RemoteDataSource remoteDataSource,
  })  : _remoteDataSource = remoteDataSource,
        super(const DocumentReaderState()) {
    on<LoadDocumentsEvent>(_onLoad);
    on<ImportDocumentEvent>(_onImport);
    on<RemoveDocumentEvent>(_onRemove);
    on<UpdateReaderSettingsEvent>(_onUpdateSettings);
    on<LoadReaderSettingsEvent>(_onLoadSettings);
    on<SaveDocReadingStateEvent>(_onSaveDocReadingState);

    // Load persisted reader settings on init
    add(const LoadReaderSettingsEvent());
  }

  final RemoteDataSource _remoteDataSource;

  Future<void> _onLoad(
    LoadDocumentsEvent event,
    Emitter<DocumentReaderState> emit,
  ) async {
    emit(state.copyWith(status: DocumentReaderStatus.loading));
    try {
      final rows = await _remoteDataSource.getDocuments();
      final docs = rows.map((json) {
        return DocumentEntity(
          id: json['id'] as String,
          userId: json['user_id'] as String,
          fileName: json['file_name'] as String,
          fileUrl: json['file_url'] as String,
          type: DocumentEntity.typeFromString(json['file_type'] as String),
          textContent: json['text_content'] as String?,
          fileSizeBytes: json['file_size'] as int?,
          createdAt: json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : null,
        );
      }).toList();

      emit(state.copyWith(status: DocumentReaderStatus.loaded, documents: docs));
    } catch (e) {
      emit(state.copyWith(
        status: DocumentReaderStatus.error,
        errorMessage: 'Khong the tai danh sach: $e',
      ));
    }
  }

  Future<void> _onImport(
    ImportDocumentEvent event,
    Emitter<DocumentReaderState> emit,
  ) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx', 'doc', 'txt'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return;

      emit(state.copyWith(status: DocumentReaderStatus.importing));

      final file = result.files.first;
      final filePath = file.path;
      if (filePath == null) {
        emit(state.copyWith(
          status: DocumentReaderStatus.loaded,
          errorMessage: 'Khong the doc file',
        ));
        return;
      }

      final ext = file.extension?.toLowerCase() ?? '';
      final docType = DocumentEntity.typeFromExtension(ext);

      // Extract text for txt/docx (store in DB for later reading)
      String? textContent;
      if (docType == DocumentType.txt) {
        textContent = await File(filePath).readAsString();
      } else if (docType == DocumentType.docx) {
        final bytes = await File(filePath).readAsBytes();
        textContent = docxToText(bytes);
      }

      // Upload to Supabase
      final json = await _remoteDataSource.uploadDocument(
        filePath: filePath,
        fileName: file.name,
        fileType: DocumentEntity.typeToString(docType),
        fileSize: file.size,
        textContent: textContent,
      );

      final doc = DocumentEntity(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        fileName: json['file_name'] as String,
        fileUrl: json['file_url'] as String,
        type: DocumentEntity.typeFromString(json['file_type'] as String),
        textContent: json['text_content'] as String?,
        fileSizeBytes: json['file_size'] as int?,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : null,
        localPath: filePath, // File just picked, still available locally
      );

      emit(state.copyWith(
        status: DocumentReaderStatus.loaded,
        documents: [doc, ...state.documents],
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DocumentReaderStatus.error,
        errorMessage: 'Import that bai: $e',
      ));
    }
  }

  Future<void> _onRemove(
    RemoveDocumentEvent event,
    Emitter<DocumentReaderState> emit,
  ) async {
    try {
      await _remoteDataSource.deleteDocument(
        id: event.documentId,
        fileUrl: event.fileUrl,
      );
      final docs = state.documents.where((d) => d.id != event.documentId).toList();
      emit(state.copyWith(documents: docs));
    } catch (e) {
      emit(state.copyWith(
        status: DocumentReaderStatus.error,
        errorMessage: 'Xoa that bai: $e',
      ));
    }
  }

  void _onUpdateSettings(
    UpdateReaderSettingsEvent event,
    Emitter<DocumentReaderState> emit,
  ) {
    final newSettings = state.settings.copyWith(
      fontSize: event.fontSize,
      lineHeight: event.lineHeight,
      readerTheme: event.readerTheme,
    );
    emit(state.copyWith(settings: newSettings));

    // Persist to SharedPreferences
    AppPreferences.setReaderSettings(
      fontSize: newSettings.fontSize,
      lineHeight: newSettings.lineHeight,
      theme: newSettings.readerTheme.name,
    );
  }

  Future<void> _onLoadSettings(
    LoadReaderSettingsEvent event,
    Emitter<DocumentReaderState> emit,
  ) async {
    final saved = await AppPreferences.getReaderSettings();
    final fontSize = saved['fontSize'] as double?;
    final lineHeight = saved['lineHeight'] as double?;
    final themeName = saved['theme'] as String?;

    ReaderTheme? theme;
    if (themeName != null) {
      theme = ReaderTheme.values.where((e) => e.name == themeName).firstOrNull;
    }

    if (fontSize != null || lineHeight != null || theme != null) {
      emit(state.copyWith(
        settings: state.settings.copyWith(
          fontSize: fontSize,
          lineHeight: lineHeight,
          readerTheme: theme,
        ),
      ));
    }
  }

  Future<void> _onSaveDocReadingState(
    SaveDocReadingStateEvent event,
    Emitter<DocumentReaderState> emit,
  ) async {
    await AppPreferences.setDocReadingState(
      documentId: event.documentId,
      currentPage: event.currentPage,
      isTextMode: event.isTextMode,
      textScrollOffset: event.textScrollOffset,
    );
  }

  static Future<Map<String, dynamic>?> getDocReadingState(String documentId) {
    return AppPreferences.getDocReadingState(documentId);
  }

  /// Download file from Supabase to local cache for reading.
  /// Returns the local file path.
  static Future<String> downloadToCache(DocumentEntity doc) async {
    if (doc.localPath != null && File(doc.localPath!).existsSync()) {
      return doc.localPath!;
    }

    final dir = await getTemporaryDirectory();
    final localFile = File('${dir.path}/${doc.id}_${doc.fileName}');

    if (localFile.existsSync()) return localFile.path;

    final response = await http.get(Uri.parse(doc.fileUrl));
    await localFile.writeAsBytes(response.bodyBytes);
    return localFile.path;
  }
}
