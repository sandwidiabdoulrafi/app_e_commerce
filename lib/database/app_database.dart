import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'app.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE panier (
            id TEXT PRIMARY KEY,
            created_at INTEGER
          )
        ''');

        await db.execute('''
          CREATE TABLE panier_produit (
            id TEXT PRIMARY KEY,
            panier_id TEXT,
            produit_id TEXT,
            name TEXT,
            categorie TEXT,
            price REAL,
            imageUrl TEXT,
            quantite INTEGER,
            note REAL
          )
        ''');
      },
    );
  }
}
