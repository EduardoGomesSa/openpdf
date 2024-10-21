import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  @override
  void dispose() {
    hideTimer?.cancel(); // Cancela o Timer ao sair da página
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          if (isCopyButtonVisible)
            IconButton(
              icon: const Icon(Icons.copy),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: selectedText!));
                setState(() {
                  selectedText = null;
                  isCopyButtonVisible = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content:
                          Text('Texto copiado para a área de transferência')),
                );
              },
            ),
          IconButton(
              onPressed: () async {
                Printing.sharePdf(bytes: await File(widget.path).readAsBytes());
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
            File(widget.path),
            enableTextSelection: true,
            onTextSelectionChanged: (details) {
              setState(() {
                selectedText =
                    details.selectedText != null && details.selectedText != ''
                        ? details.selectedText!
                        : '';
                isCopyButtonVisible = details.selectedText != null &&
                    details.selectedText!
                        .isNotEmpty;
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

  //  void showCopyButton(String selectedText) {
  //   // Exibe um SnackBar com a opção de copiar o texto selecionado
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text(''),
  //       action: SnackBarAction(
  //         label: 'Copiar',
  //         onPressed: () {
  //           Clipboard.setData(ClipboardData(text: selectedText));
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             const SnackBar(content: Text('Texto copiado para a área de transferência')),
  //           );
  //         },
  //       ),
  //     ),
  //   );
  // }
}
