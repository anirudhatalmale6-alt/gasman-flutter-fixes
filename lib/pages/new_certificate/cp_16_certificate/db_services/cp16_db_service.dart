
import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/cp_16_certificate.dart';


class Cp16DbService {
  static Database? _database;

  static const String _databaseName = 'cp16_certificates.db';
  static const String _tableName = 'cp16_certificates';

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, _databaseName);

    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        data TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');
  }

  static Future<int> saveCertificate(Cp16Certificate certificate) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    final data = jsonEncode(certificate.toMap());

    if (certificate.id == null) {
      return db.insert(
        _tableName,
        {
          'data': data,
          'createdAt': now,
          'updatedAt': now,
        },
      );
    }

    await db.update(
      _tableName,
      {
        'data': data,
        'updatedAt': now,
      },
      where: 'id = ?',
      whereArgs: [certificate.id],
    );

    return certificate.id!;
  }

  static Future<List<Cp16Certificate>> getCertificates() async {
    final db = await database;
    final rows = await db.query(_tableName, orderBy: 'id DESC');

    return rows.map((row) {
      final decoded =
      jsonDecode(row['data'] as String) as Map<String, dynamic>;
      decoded['id'] = row['id'];
      return Cp16Certificate.fromMap(decoded);
    }).toList();
  }

  static Future<Cp16Certificate?> getCertificateById(int id) async {
    final db = await database;

    final rows = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (rows.isEmpty) return null;

    final decoded =
    jsonDecode(rows.first['data'] as String) as Map<String, dynamic>;
    decoded['id'] = rows.first['id'];

    return Cp16Certificate.fromMap(decoded);
  }

  static Future<void> deleteCertificate(int id) async {
    final db = await database;
    await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }
}