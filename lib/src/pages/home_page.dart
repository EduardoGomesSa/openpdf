import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:openpdf/src/controllers/last_pdf_controller.dart';
import 'package:openpdf/src/models/pdf_viewer_model.dart';
import 'package:openpdf/src/pages/widgets/custom_app_bar_widget.dart';
import 'package:openpdf/src/pages/widgets/pdf_viewer_page.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:path/path.dart' as path;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late StreamSubscription _intentSub;
  final controller = LastPdfController();
  List<PdfViewerModel> listPdfOpens = [];

  final _sharedFiles = <SharedMediaFile>[];

  @override
  void initState() {
    super.initState();

    _getAllLastPdfs();

    // Listen to media sharing coming from outside the app while the app is in the memory.
    _intentSub = ReceiveSharingIntent.instance.getMediaStream().listen((value) {
      setState(() {
        _sharedFiles.clear();
        _sharedFiles.addAll(value);
        if (_sharedFiles.isNotEmpty) {
          _addPdf(_sharedFiles.first.path);
        }
      });
    }, onError: (err) {});

    // Get the media sharing coming from outside the app while the app is closed.
    ReceiveSharingIntent.instance.getInitialMedia().then((value) {
      setState(() {
        _sharedFiles.clear();
        _sharedFiles.addAll(value);

        if (_sharedFiles.isNotEmpty) {
          _addPdf(_sharedFiles.first.path);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  PdfViewerPage(path: _sharedFiles.first.path),
            ),
          );
        }

        // Tell the library that we are done processing the intent.
        ReceiveSharingIntent.instance.reset();
      });
    });
  }

  void _addPdf(String path) async {
    await controller.addPdf(path);

    _getAllLastPdfs();
  }

  void _getAllLastPdfs() async {
    var result = await controller.getAllPdfs();

    setState(() {
      listPdfOpens = result;
    });
  }

  @override
  void dispose() {
    _intentSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yy HH:mm:ss');

    return Scaffold(
      appBar: const CustomAppBarWidget(),
      body: listPdfOpens.isNotEmpty
          ? ListView.builder(
              itemCount: listPdfOpens.length,
              itemBuilder: (context, index) {
                final pdf = listPdfOpens[index];
                final fileName =
                    path.basename(pdf.path ?? "Caminho não encontrado");

                return Column(
                  children: [
                    if(index == 0)
                    const Padding(
                      padding: EdgeInsets.only(top: 15, bottom: 10),
                      child: Text("Últimos PDFs abertos", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PdfViewerPage(path: pdf.path!),
                            ),
                          );
                        },
                        child: Text(
                            '$fileName - ${pdf.createdAt != null ? dateFormat.format(pdf.createdAt!) : "Horário não disponível"}'),
                      ),
                    ),
                  ],
                );
              },
            )
          : const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Nenhum arquivo selecionado"),
                  Text("Nenhum PDF aberto")
                ],
              ),
            ),
    );
  }
}
