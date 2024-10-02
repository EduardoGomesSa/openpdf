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
        // Criação inicial da tabela
        return db.execute(
            'CREATE TABLE lasts_pdf_opens(id INTEGER PRIMARY KEY, path_pdf TEXT, created_at TEXT DEFAULT CURRENT_TIMESTAMP)');
      },
      version: 2, // Incrementa a versão do banco de dados
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Adiciona a nova coluna sem valor padrão dinâmico
          await db.execute(
            'ALTER TABLE lasts_pdf_opens ADD COLUMN created_at TEXT',
          );

          // Atualiza as linhas existentes com a data e hora atuais
          await db.execute(
            'UPDATE lasts_pdf_opens SET created_at = CURRENT_TIMESTAMP WHERE created_at IS NULL',
          );
        }
      },
    );
  }
}
