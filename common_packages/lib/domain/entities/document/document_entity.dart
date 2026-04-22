import 'package:equatable/equatable.dart';

enum DocumentType { pdf, docx, txt, unknown }

class DocumentEntity extends Equatable {
  const DocumentEntity({
    required this.id,
    required this.userId,
    required this.fileName,
    required this.fileUrl,
    required this.type,
    this.textContent,
    this.fileSizeBytes,
    this.createdAt,
    this.localPath,
  });

  final String id;
  final String userId;
  final String fileName;
  final String fileUrl;
  final DocumentType type;
  final String? textContent;
  final int? fileSizeBytes;
  final DateTime? createdAt;

  /// Local cached file path (downloaded from Supabase for reading)
  final String? localPath;

  String get displayName {
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex > 0) return fileName.substring(0, dotIndex);
    return fileName;
  }

  String get extension {
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex > 0) return fileName.substring(dotIndex + 1).toLowerCase();
    return '';
  }

  String get fileSizeFormatted {
    if (fileSizeBytes == null) return '';
    final kb = fileSizeBytes! / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';
    final mb = kb / 1024;
    return '${mb.toStringAsFixed(1)} MB';
  }

  static DocumentType typeFromExtension(String ext) {
    switch (ext.toLowerCase()) {
      case 'pdf':
        return DocumentType.pdf;
      case 'docx':
      case 'doc':
        return DocumentType.docx;
      case 'txt':
        return DocumentType.txt;
      default:
        return DocumentType.unknown;
    }
  }

  static String typeToString(DocumentType type) {
    switch (type) {
      case DocumentType.pdf:
        return 'pdf';
      case DocumentType.docx:
        return 'docx';
      case DocumentType.txt:
        return 'txt';
      case DocumentType.unknown:
        return 'unknown';
    }
  }

  static DocumentType typeFromString(String s) {
    switch (s) {
      case 'pdf':
        return DocumentType.pdf;
      case 'docx':
        return DocumentType.docx;
      case 'txt':
        return DocumentType.txt;
      default:
        return DocumentType.unknown;
    }
  }

  DocumentEntity copyWith({String? localPath, String? textContent}) {
    return DocumentEntity(
      id: id,
      userId: userId,
      fileName: fileName,
      fileUrl: fileUrl,
      type: type,
      textContent: textContent ?? this.textContent,
      fileSizeBytes: fileSizeBytes,
      createdAt: createdAt,
      localPath: localPath ?? this.localPath,
    );
  }

  @override
  List<Object?> get props => [id, userId, fileName, fileUrl, type, fileSizeBytes, createdAt];
}
