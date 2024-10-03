import 'dart:async';
import 'package:openpdf/src/models/pdf_viewer_model.dart';
import 'package:openpdf/src/repositories/databases/db.dart';
import 'package:sqflite/sqflite.dart';

class LastPdfRepository {
  Future<int> insert(String pathPdf) async {
    final db = await Db.connection();

    var pdfsAlreadyOpens = await getAll();

    if (pdfsAlreadyOpens.length >= 10) {
      db.delete('lasts_pdf_opens',
          where: 'ID = ?', whereArgs: [pdfsAlreadyOpens.last.id]);
    }

    var saved = await db.insert(
      'lasts_pdf_opens',
      {'path_pdf': pathPdf, 'created_at': DateTime.now().toString()},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return saved;
  }

  Future<List<PdfViewerModel>> getAll() async {
    
    final db = await Db.connection();

    final result = await db.query('lasts_pdf_opens', orderBy: 'ID DESC');

    List<PdfViewerModel> list = result.map((row) {
      return PdfViewerModel(
        id: row['ID'] != null ? row['ID'] as int : 0,
        path: row['path_pdf'] as String,
        createdAt: row['created_at'] != null ? DateTime.parse(row['created_at'] as String) : null,
      );
    }).toList();

    return list;
  }
}
