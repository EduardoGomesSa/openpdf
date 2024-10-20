import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
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

  @override
  void dispose() {
    hideTimer?.cancel(); // Cancela o Timer ao sair da página
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SfPdfViewer.file(
            File(widget.path),
            enableTextSelection: true,
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
          // Colocando o Positioned depois do PDFView para garantir que ele seja exibido por cima
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
}
