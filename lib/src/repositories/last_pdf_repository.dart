import 'dart:async';

import 'package:openpdf/src/models/pdf_viewer_model.dart';
import 'package:openpdf/src/repositories/databases/db.dart';
import 'package:sqflite/sqflite.dart';

class LastPdfRepository {
  Future<int> insert(String pathPdf) async {
    final db = await Db.connection();

    var saved = await db.insert(
      'lasts_pdf_opens',
      {'path_pdf': pathPdf},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return saved;
  }

  Future<List<PdfViewerModel>> getAll() async {
    final db = await Db.connection();

    final result = await db.query('lasts_pdf_opens');

    List<PdfViewerModel> list = result.map((row) {
      return PdfViewerModel(
          id: row['id'] != null ? row['id'] as int : 0, path: row['path_pdf'] as String);
    }).toList();

    return list;
  }
}
