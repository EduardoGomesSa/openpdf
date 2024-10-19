import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
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
          PDFView(
            filePath: widget.path,
            enableSwipe: true,
            swipeHorizontal: true,
            autoSpacing: true,
            pageFling: true,
            onRender: (pages) {
              setState(() {
                totalPages = pages;
              });
            },
            onPageChanged: (page, total) {
              setState(() {
                currentPage = page;
                showPageIndicator = true;
              });

              // Reinicia o temporizador para esconder a faixa após 5 segundos
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
