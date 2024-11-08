import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:openpdf/src/pages/widgets/custom_app_bar_widget.dart';
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerPage extends StatefulWidget {
  const PdfViewerPage({super.key, required this.path});

  final String path;

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  int? currentPage = 0;
  int? totalPages = 0;
  bool showPageIndicator = false;
  Timer? hideTimer;
  String? selectedText = "";
  bool isCopyButtonVisible = false;
  late PdfViewerController pdfViewerController;

  @override
  void initState() {
    super.initState();

    pdfViewerController = PdfViewerController();
  }

  @override
  void dispose() {
    hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(
        actions: [
          if (isCopyButtonVisible)
            IconButton(
                icon: const Icon(Icons.copy), onPressed: copyTextToClipboard),
          IconButton(
              onPressed: () async {
                Printing.sharePdf(
                  filename: widget.path.split('/').last,
                  bytes: await File(widget.path).readAsBytes(),
                );
              },
              icon: const Icon(
                Icons.share,
                color: Colors.black,
              )),
        ],
      ),
      body: Stack(
        children: [
          SfPdfViewer.file(
            canShowScrollHead: showPageIndicator,
            canShowScrollStatus: false,
            File(widget.path),
            enableTextSelection: true,
            controller: pdfViewerController,
            onTextSelectionChanged: (details) {
              setState(() {
                selectedText =
                    details.selectedText != null && details.selectedText != ''
                        ? details.selectedText!
                        : '';
                isCopyButtonVisible = details.selectedText != null &&
                    details.selectedText!.isNotEmpty;
              });
            },
            onDocumentLoaded: (PdfDocumentLoadedDetails details) {
              setState(() {
                totalPages = details.document.pages.count;
              });
            },
            onPageChanged: (PdfPageChangedDetails details) {
              setState(() {
                currentPage = details.newPageNumber;
                showPageIndicator = true;
              });
              hideTimer?.cancel();
              hideTimer = Timer(const Duration(seconds: 3), () {
                setState(() {
                  showPageIndicator = false;
                });
              });
            },
          ),
          if (showPageIndicator)
            Positioned(
              bottom: 5,
              left: 0,
              right: 0,
              child: Container(
                alignment: Alignment.center,
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                color: Colors.black54,
                child: Text(
                  'Página ${currentPage! + 1} de $totalPages',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void copyTextToClipboard() {
    if (selectedText != null && selectedText!.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: selectedText!)).then((_) {
        setState(() {
          selectedText = null;
          isCopyButtonVisible = false;
        });

        pdfViewerController.jumpToPage(currentPage!);
      });
    }
  }
}
