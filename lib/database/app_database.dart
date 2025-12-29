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
      version: 2, // version supérieure pour gérer l'upgrade
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
            note REAL,
            description TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE users (
            id TEXT PRIMARY KEY,
            nom TEXT,
            prenom TEXT,
            email TEXT,
            telephone TEXT,
            motDePasse TEXT,
            imgProfile TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE commande (
            id TEXT PRIMARY KEY,
            client_id TEXT,
            date INTEGER,
            statut TEXT,
            total REAL
          )
        ''');
        await db.execute('''
          CREATE TABLE produit_commande (
            id TEXT PRIMARY KEY,
            commande_id TEXT,
            panier_id TEXT,
            produit_id TEXT,
            name TEXT,
            description TEXT,
            categorie TEXT,
            price REAL,
            image_url TEXT,
            quantite INTEGER,
            note REAL
          )
        ''');


      },
      
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE panier_produit ADD COLUMN description TEXT'
          );
        }
      },
    );
  }
}
