import 'dart:async';

import 'package:flutter/material.dart';
import 'package:openpdf/src/controllers/last_pdf_controller.dart';
import 'package:openpdf/src/models/pdf_viewer_model.dart';
import 'package:openpdf/src/pages/pdf_viewer_page.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

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

        print(_sharedFiles.map((f) => f.toMap()));
      });
    }, onError: (err) {
      print("getIntentDataStream error: $err");
    });

    // Get the media sharing coming from outside the app while the app is closed.
    ReceiveSharingIntent.instance.getInitialMedia().then((value) {
      setState(() {
        _sharedFiles.clear();
        _sharedFiles.addAll(value);

        if (_sharedFiles.isNotEmpty) {
          _addPdf(_sharedFiles.first.path);
        }
        print(_sharedFiles.map((f) => f.toMap()));

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
      print("CAMINHO --> ${listPdfOpens.first.path}");
    });
  }

  @override
  void dispose() {
    _intentSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visualizador de app'),
      ),
      body: _sharedFiles.isNotEmpty && _sharedFiles.first.path.isNotEmpty
          ? PdfViewerPage(path: _sharedFiles.first.path)
          : listPdfOpens != null && listPdfOpens!.isNotEmpty
              ? ListView.builder(
                  itemCount: listPdfOpens!.length,
                  itemBuilder: (context, index) {
                    final pdf = listPdfOpens![index];
                    return ListTile(
                      title: Text(pdf.path ?? "Caminho não encontrado"),
                      subtitle: Text("PDF #${index + 1}"),
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
