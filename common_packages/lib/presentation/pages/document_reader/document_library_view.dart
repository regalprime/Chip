import 'package:common_packages/base/design_system/widgets/ds_error_dialog.dart';
import 'package:common_packages/base/extensions/context_extension.dart';
import 'package:common_packages/domain/entities/document/document_entity.dart';
import 'package:common_packages/presentation/blocs/document_reader/document_reader_bloc.dart';
import 'package:common_packages/presentation/pages/document_reader/document_reader_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DocumentLibraryView extends StatelessWidget {
  const DocumentLibraryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thu vien')),
      body: BlocConsumer<DocumentReaderBloc, DocumentReaderState>(
        listener: (context, state) {
          if (state.status == DocumentReaderStatus.error && state.errorMessage != null) {
            DSErrorDialog.show(context, message: state.errorMessage!);
          }
        },
        builder: (context, state) {
          if (state.status == DocumentReaderStatus.loading && state.documents.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == DocumentReaderStatus.importing) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Dang xu ly...'),
                ],
              ),
            );
          }

          if (state.documents.isEmpty) {
            return _EmptyLibrary(
              onImport: () => context.read<DocumentReaderBloc>().add(const ImportDocumentEvent()),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            itemCount: state.documents.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _DocumentCard(document: state.documents[index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.read<DocumentReaderBloc>().add(const ImportDocumentEvent()),
        icon: const Icon(Icons.add),
        label: const Text('Import'),
      ),
    );
  }
}

// ─── Empty State ────────────────────────────────────────────────────────────

class _EmptyLibrary extends StatelessWidget {
  const _EmptyLibrary({required this.onImport});

  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.menu_book_outlined,
                size: 48,
                color: theme.colorScheme.primary.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Thu vien trong',
              style: theme.textTheme.headlineLarge?.copyWith(fontSize: 20),
            ),
            const SizedBox(height: 8),
            Text(
              'Import file PDF, Word hoac TXT de bat dau doc',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onImport,
              icon: const Icon(Icons.file_upload_outlined),
              label: const Text('Import file'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Document Card ──────────────────────────────────────────────────────────

class _DocumentCard extends StatelessWidget {
  const _DocumentCard({required this.document});

  final DocumentEntity document;

  IconData _iconForType(DocumentType type) {
    switch (type) {
      case DocumentType.pdf:
        return Icons.picture_as_pdf_outlined;
      case DocumentType.docx:
        return Icons.description_outlined;
      case DocumentType.txt:
        return Icons.text_snippet_outlined;
      case DocumentType.unknown:
        return Icons.insert_drive_file_outlined;
    }
  }

  Color _colorForType(DocumentType type) {
    switch (type) {
      case DocumentType.pdf:
        return const Color(0xFFE53935);
      case DocumentType.docx:
        return const Color(0xFF1565C0);
      case DocumentType.txt:
        return const Color(0xFF43A047);
      case DocumentType.unknown:
        return const Color(0xFF757575);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final typeColor = _colorForType(document.type);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<DocumentReaderBloc>(),
              child: DocumentReaderScreen(document: document),
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.appColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.appColors.divider),
        ),
        child: Row(
          children: [
            // File type icon
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: typeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _iconForType(document.type),
                color: typeColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    document.displayName,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _InfoChip(
                        label: document.extension.toUpperCase(),
                        color: typeColor,
                      ),
                      const SizedBox(width: 8),
                      if (document.fileSizeBytes != null)
                        Text(
                          document.fileSizeFormatted,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // Delete button
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                size: 20,
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
              onPressed: () {
                _confirmDelete(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xoa tai lieu?'),
        content: Text('Ban co chac muon xoa "${document.displayName}"?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Huy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<DocumentReaderBloc>().add(
                    RemoveDocumentEvent(documentId: document.id, fileUrl: document.fileUrl),
                  );
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Xoa'),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
