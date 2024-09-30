import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:openpdf/src/pages/pdf_viewer_page.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late StreamSubscription _intentSub;

  final _sharedFiles = <SharedMediaFile>[];

  @override
  void initState() {
    super.initState();

    // Listen to media sharing coming from outside the app while the app is in the memory.
    _intentSub = ReceiveSharingIntent.instance.getMediaStream().listen((value) {
      setState(() {
        _sharedFiles.clear();
        _sharedFiles.addAll(value);

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
        print(_sharedFiles.map((f) => f.toMap()));

        // Tell the library that we are done processing the intent.
        ReceiveSharingIntent.instance.reset();
      });
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
        body: _sharedFiles.isNotEmpty && _sharedFiles.first.path.isNotEmpty ? 
        PdfViewerPage(path: _sharedFiles.first.path) : const Center(child: Text("Nenhum arquivo selecionado"),),
      );
  }
}