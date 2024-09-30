import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;

abstract class Db {
  static Future<sql.Database> connection() async {
    WidgetsFlutterBinding.ensureInitialized();

    final dbPath = await sql.getDatabasesPath();

    return sql.openDatabase(
      path.join(dbPath, 'openpdf.db'),
      onCreate: (db, version) {
        return db.execute(
            'CREATE TABLE lasts_pdf_opens(ID INTEGER PRIMARY KEY, path_pdf TEXT)');
      },
      version: 1,
    );
  }
}
