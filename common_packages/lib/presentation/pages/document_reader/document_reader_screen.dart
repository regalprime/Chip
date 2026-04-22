import 'dart:async';

import 'package:common_packages/base/design_system/widgets/ds_error_dialog.dart';
import 'package:common_packages/domain/entities/document/document_entity.dart';
import 'package:common_packages/presentation/blocs/document_reader/document_reader_bloc.dart';
import 'package:common_packages/presentation/pages/document_reader/reader_settings_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdfrx/pdfrx.dart';

class DocumentReaderScreen extends StatefulWidget {
  const DocumentReaderScreen({super.key, required this.document});

  final DocumentEntity document;

  @override
  State<DocumentReaderScreen> createState() => _DocumentReaderScreenState();
}

class _DocumentReaderScreenState extends State<DocumentReaderScreen> {
  bool _showControls = true;

  // For PDF: toggle between native PDF view and extracted text view
  bool _isTextMode = false;
  String? _extractedText;
  bool _isExtracting = false;

  // Local file path (downloaded from Supabase or picked locally)
  String? _localPath;
  bool _isDownloading = true;

  // Restored reading state
  int? _restoredPage;
  double? _restoredScrollOffset;

  @override
  void initState() {
    super.initState();
    _prepareFile();
  }

  Future<void> _prepareFile() async {
    try {
      // Restore saved reading state
      final savedState = await DocumentReaderBloc.getDocReadingState(widget.document.id);
      if (savedState != null && mounted) {
        final savedTextMode = savedState['isTextMode'] as bool? ?? false;
        _restoredPage = savedState['currentPage'] as int?;
        _restoredScrollOffset = (savedState['textScrollOffset'] as num?)?.toDouble();
        _isTextMode = savedTextMode;
      }

      final path = await DocumentReaderBloc.downloadToCache(widget.document);
      if (mounted) {
        setState(() {
          _localPath = path;
          _isDownloading = false;
        });
        // If restored to text mode, extract text automatically
        if (_isTextMode && widget.document.type == DocumentType.pdf) {
          _extractTextFromPdf();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDownloading = false);
        DSErrorDialog.show(context, message: 'Khong the tai file: $e');
      }
    }
  }

  void _saveReadingState({int? page, bool? textMode}) {
    context.read<DocumentReaderBloc>().add(SaveDocReadingStateEvent(
      documentId: widget.document.id,
      currentPage: page,
      isTextMode: textMode,
    ));
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
  }

  Future<void> _extractTextFromPdf() async {
    if (_extractedText != null) {
      setState(() => _isTextMode = true);
      return;
    }
    if (_localPath == null) return;

    setState(() => _isExtracting = true);

    try {
      final doc = await PdfDocument.openFile(_localPath!);
      final rawPages = <String>[];

      for (int i = 0; i < doc.pages.length; i++) {
        final pageText = await doc.pages[i].loadText();
        final text = pageText.fullText.trim();
        if (text.isNotEmpty) {
          rawPages.add(text);
        }
      }

      final rawText = rawPages.join('\n\n');
      final cleaned = _reflowPdfText(rawText);

      if (mounted) {
        setState(() {
          _extractedText = cleaned;
          _isTextMode = true;
          _isExtracting = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isExtracting = false);
        DSErrorDialog.show(context, message: 'Khong the trich xuat text: $e');
      }
    }
  }

  /// Reflow PDF text: join soft-wrapped lines, keep real paragraph breaks.
  ///
  /// PDF line breaks are often just because the line hit the page margin,
  /// not because the author intended a new paragraph. This function detects
  /// soft wraps and joins them, while preserving intentional paragraph breaks.
  static String _reflowPdfText(String raw) {
    final text = raw.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    final lines = text.split('\n');
    if (lines.isEmpty) return text;

    // Calculate median non-empty line length to detect "short" lines.
    // In a typical PDF, most lines are similar length (page width).
    // Lines significantly shorter are likely end-of-paragraph or headings.
    final lengths = lines
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .map((l) => l.length)
        .toList()
      ..sort();
    final medianLen = lengths.isNotEmpty ? lengths[lengths.length ~/ 2] : 60;
    final shortThreshold = (medianLen * 0.55).round();

    final buffer = StringBuffer();
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();

      // Empty line → always a paragraph break
      if (line.isEmpty) {
        buffer.write('\n\n');
        continue;
      }

      buffer.write(line);

      if (i >= lines.length - 1) continue; // last line, nothing to join

      final nextLine = lines[i + 1].trim();

      // Next line empty → paragraph break handled next iteration
      if (nextLine.isEmpty) continue;

      if (_isHardBreak(line, nextLine, shortThreshold)) {
        buffer.write('\n');
      } else {
        // Soft wrap → join words
        if (line.endsWith('-') && nextLine.isNotEmpty) {
          // Hyphenated word split: remove hyphen and join directly
          // e.g. "impor-" + "tant" → "important"
          final s = buffer.toString();
          buffer.clear();
          buffer.write(s.substring(0, s.length - 1));
        } else {
          buffer.write(' ');
        }
      }
    }

    return buffer
        .toString()
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }

  /// Is the break between [line] and [nextLine] an intentional hard break?
  static bool _isHardBreak(String line, String nextLine, int shortThreshold) {
    final isShort = line.length < shortThreshold;

    // Sentence-ending punctuation
    final endsWithPunctuation =
        RegExp(r'[.!?:;…""\)\]»。！？]$').hasMatch(line);

    // Next line starts with uppercase, Vietnamese uppercase, or special chars
    final nextStartsUpper = RegExp(
      r'^[A-ZÀÁẢÃẠĂẮẰẲẴẶÂẤẦẨẪẬĐÈÉẺẼẸÊẾỀỂỄỆÌÍỈĨỊÒÓỎÕỌÔỐỒỔỖỘƠỚỜỞỠỢÙÚỦŨỤƯỨỪỬỮỰỲÝỶỸỴ""\(\[«]',
    ).hasMatch(nextLine);

    // Next line is a bullet/list item
    final nextIsBullet = RegExp(r'^[\-•●▪▸►]\s').hasMatch(nextLine) ||
        RegExp(r'^\d+[.)]\s').hasMatch(nextLine);

    // Line is ALL CAPS heading
    final isHeading = isShort &&
        line.length > 2 &&
        line == line.toUpperCase() &&
        RegExp(r'[A-Z]').hasMatch(line);

    // --- Decision rules (order matters) ---

    // Bullet/list → always hard break
    if (nextIsBullet) return true;

    // ALL-CAPS heading → hard break
    if (isHeading) return true;

    // Short line + ends with punctuation → almost certainly end of paragraph
    if (isShort && endsWithPunctuation) return true;

    // Short line + next starts with uppercase → likely new paragraph
    if (isShort && nextStartsUpper) return true;

    // Ends with punctuation + next starts uppercase → new sentence/paragraph
    // (This is the most common pattern for paragraph breaks)
    if (endsWithPunctuation && nextStartsUpper) return true;

    // If none of the above → soft wrap (join)
    return false;
  }

  @override
  Widget build(BuildContext context) {
    // Downloading file from Supabase
    if (_isDownloading || _isExtracting) {
      return Scaffold(
        backgroundColor: const Color(0xFF2C2C2C),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(height: 16),
              Text(
                _isExtracting ? 'Dang trich xuat van ban...' : 'Dang tai file...',
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    // File not available
    if (_localPath == null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.document.displayName)),
        body: const Center(child: Text('Khong the mo file nay.')),
      );
    }

    final isPdf = widget.document.type == DocumentType.pdf;

    if (isPdf && !_isTextMode) {
      return _PdfReaderView(
        document: widget.document,
        localPath: _localPath!,
        showControls: _showControls,
        onToggleControls: _toggleControls,
        onSwitchToText: () {
          _extractTextFromPdf();
          _saveReadingState(textMode: true);
        },
        initialPage: _restoredPage,
        onPageChanged: (page) {
          _saveReadingState(page: page);
        },
      );
    }

    // Text mode (for txt/docx OR extracted PDF text)
    final textContent = isPdf ? _extractedText : widget.document.textContent;

    return _TextReaderView(
      document: widget.document,
      textContent: textContent ?? 'Khong the doc noi dung file nay.',
      showControls: _showControls,
      onToggleControls: _toggleControls,
      canSwitchToPdf: isPdf,
      onSwitchToPdf: isPdf
          ? () {
              setState(() => _isTextMode = false);
              _saveReadingState(textMode: false);
            }
          : null,
      initialScrollOffset: _restoredScrollOffset,
      onScrollChanged: (offset) {
        _saveReadingState(textMode: true);
        context.read<DocumentReaderBloc>().add(SaveDocReadingStateEvent(
          documentId: widget.document.id,
          textScrollOffset: offset,
        ));
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PDF Reader - Native rendering with pinch zoom
// ═══════════════════════════════════════════════════════════════════════════════

class _PdfReaderView extends StatefulWidget {
  const _PdfReaderView({
    required this.document,
    required this.localPath,
    required this.showControls,
    required this.onToggleControls,
    required this.onSwitchToText,
    this.initialPage,
    this.onPageChanged,
  });

  final DocumentEntity document;
  final String localPath;
  final bool showControls;
  final VoidCallback onToggleControls;
  final VoidCallback onSwitchToText;
  final int? initialPage;
  final ValueChanged<int>? onPageChanged;

  @override
  State<_PdfReaderView> createState() => _PdfReaderViewState();
}

class _PdfReaderViewState extends State<_PdfReaderView> {
  final _controller = PdfViewerController();
  int _currentPage = 1;
  int _totalPages = 0;
  bool _didRestorePage = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialPage != null) {
      _currentPage = widget.initialPage!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C2C2C),
      body: Stack(
        children: [
          // PDF viewer
          GestureDetector(
            onTap: widget.onToggleControls,
            child: PdfViewer.file(
              widget.localPath,
              controller: _controller,
              params: PdfViewerParams(
                margin: 8,
                backgroundColor: const Color(0xFF2C2C2C),
                onPageChanged: (pageNumber) {
                  if (pageNumber != null) {
                    setState(() => _currentPage = pageNumber);
                    widget.onPageChanged?.call(pageNumber);
                  }
                },
                onViewerReady: (document, controller) {
                  setState(() {
                    _totalPages = document.pages.length;
                  });
                  // Restore to saved page
                  if (!_didRestorePage && widget.initialPage != null && widget.initialPage! > 1) {
                    _didRestorePage = true;
                    Future.microtask(() {
                      controller.goToPage(pageNumber: widget.initialPage!);
                    });
                  }
                },
              ),
            ),
          ),

          // Top bar
          if (widget.showControls)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Expanded(
                          child: Text(
                            widget.document.displayName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Switch to text mode button
                        IconButton(
                          icon: const Icon(Icons.auto_stories, color: Colors.white),
                          tooltip: 'Che do doc sach',
                          onPressed: widget.onSwitchToText,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Bottom page indicator
          if (widget.showControls && _totalPages > 0)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Switch to text mode
                        GestureDetector(
                          onTap: widget.onSwitchToText,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.auto_stories, color: Colors.white, size: 16),
                                SizedBox(width: 6),
                                Text(
                                  'Doc dang sach',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Page indicator
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Trang $_currentPage / $_totalPages',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Text Reader - E-reader style for txt/docx/extracted PDF text
// ═══════════════════════════════════════════════════════════════════════════════

class _TextReaderView extends StatefulWidget {
  const _TextReaderView({
    required this.document,
    required this.textContent,
    required this.showControls,
    required this.onToggleControls,
    this.canSwitchToPdf = false,
    this.onSwitchToPdf,
    this.initialScrollOffset,
    this.onScrollChanged,
  });

  final DocumentEntity document;
  final String textContent;
  final bool showControls;
  final VoidCallback onToggleControls;
  final bool canSwitchToPdf;
  final VoidCallback? onSwitchToPdf;
  final double? initialScrollOffset;
  final ValueChanged<double>? onScrollChanged;

  @override
  State<_TextReaderView> createState() => _TextReaderViewState();
}

class _TextReaderViewState extends State<_TextReaderView> {
  late final ScrollController _scrollController;
  Timer? _scrollDebounce;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(
      initialScrollOffset: widget.initialScrollOffset ?? 0,
    );
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollDebounce?.cancel();
    _scrollController.removeListener(_onScroll);
    // Save final position on dispose (only if attached to a view)
    if (_scrollController.hasClients) {
      widget.onScrollChanged?.call(_scrollController.offset);
    }
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    _scrollDebounce?.cancel();
    _scrollDebounce = Timer(const Duration(milliseconds: 500), () {
      widget.onScrollChanged?.call(_scrollController.offset);
    });
  }

  Color _backgroundColor(ReaderTheme theme) {
    switch (theme) {
      case ReaderTheme.light:
        return const Color(0xFFFAFAFA);
      case ReaderTheme.sepia:
        return const Color(0xFFF5E6CA);
      case ReaderTheme.dark:
        return const Color(0xFF1A1A1A);
    }
  }

  Color _textColor(ReaderTheme theme) {
    switch (theme) {
      case ReaderTheme.light:
        return const Color(0xFF2C2C2C);
      case ReaderTheme.sepia:
        return const Color(0xFF4A3728);
      case ReaderTheme.dark:
        return const Color(0xFFD4D4D4);
    }
  }

  Color _controlColor(ReaderTheme theme) {
    switch (theme) {
      case ReaderTheme.light:
        return Colors.black;
      case ReaderTheme.sepia:
        return const Color(0xFF4A3728);
      case ReaderTheme.dark:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DocumentReaderBloc, DocumentReaderState>(
      buildWhen: (prev, curr) => prev.settings != curr.settings,
      builder: (context, state) {
        final settings = state.settings;
        final bgColor = _backgroundColor(settings.readerTheme);
        final txtColor = _textColor(settings.readerTheme);
        final ctrlColor = _controlColor(settings.readerTheme);

        return Scaffold(
          backgroundColor: bgColor,
          body: GestureDetector(
            onTap: widget.onToggleControls,
            child: Stack(
              children: [
                // Content
                SafeArea(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 60,
                    ),
                    child: SelectableText(
                      widget.textContent,
                      style: TextStyle(
                        fontSize: settings.fontSize,
                        height: settings.lineHeight,
                        color: txtColor,
                        fontFamily: 'Tinos',
                      ),
                    ),
                  ),
                ),

                // Top controls
                if (widget.showControls)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      color: bgColor.withOpacity(0.95),
                      child: SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                          child: Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.arrow_back, color: ctrlColor),
                                onPressed: () => Navigator.pop(context),
                              ),
                              Expanded(
                                child: Text(
                                  widget.document.displayName,
                                  style: TextStyle(
                                    color: ctrlColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (widget.canSwitchToPdf)
                                IconButton(
                                  icon: Icon(Icons.picture_as_pdf, color: ctrlColor),
                                  tooltip: 'Xem dang PDF',
                                  onPressed: widget.onSwitchToPdf,
                                ),
                              IconButton(
                                icon: Icon(Icons.tune, color: ctrlColor),
                                onPressed: () => _showSettings(context),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                // Bottom quick controls
                if (widget.showControls)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      color: bgColor.withOpacity(0.95),
                      child: SafeArea(
                        top: false,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Font size decrease
                              _QuickButton(
                                icon: Icons.text_decrease,
                                color: ctrlColor,
                                onTap: () {
                                  final newSize = (settings.fontSize - 2).clamp(10.0, 40.0);
                                  context.read<DocumentReaderBloc>().add(
                                        UpdateReaderSettingsEvent(fontSize: newSize),
                                      );
                                },
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: ctrlColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${settings.fontSize.toInt()}',
                                  style: TextStyle(
                                    color: ctrlColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Font size increase
                              _QuickButton(
                                icon: Icons.text_increase,
                                color: ctrlColor,
                                onTap: () {
                                  final newSize = (settings.fontSize + 2).clamp(10.0, 40.0);
                                  context.read<DocumentReaderBloc>().add(
                                        UpdateReaderSettingsEvent(fontSize: newSize),
                                      );
                                },
                              ),
                              const SizedBox(width: 24),
                              // Theme toggles
                              _ThemeDot(
                                color: const Color(0xFFFAFAFA),
                                isSelected: settings.readerTheme == ReaderTheme.light,
                                onTap: () => context.read<DocumentReaderBloc>().add(
                                      const UpdateReaderSettingsEvent(readerTheme: ReaderTheme.light),
                                    ),
                              ),
                              const SizedBox(width: 8),
                              _ThemeDot(
                                color: const Color(0xFFF5E6CA),
                                isSelected: settings.readerTheme == ReaderTheme.sepia,
                                onTap: () => context.read<DocumentReaderBloc>().add(
                                      const UpdateReaderSettingsEvent(readerTheme: ReaderTheme.sepia),
                                    ),
                              ),
                              const SizedBox(width: 8),
                              _ThemeDot(
                                color: const Color(0xFF1A1A1A),
                                isSelected: settings.readerTheme == ReaderTheme.dark,
                                onTap: () => context.read<DocumentReaderBloc>().add(
                                      const UpdateReaderSettingsEvent(readerTheme: ReaderTheme.dark),
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<DocumentReaderBloc>(),
        child: const ReaderSettingsSheet(),
      ),
    );
  }
}

// ─── Shared Widgets ─────────────────────────────────────────────────────────

class _QuickButton extends StatelessWidget {
  const _QuickButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }
}

class _ThemeDot extends StatelessWidget {
  const _ThemeDot({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.withOpacity(0.4),
            width: isSelected ? 3 : 1,
          ),
        ),
      ),
    );
  }
}
