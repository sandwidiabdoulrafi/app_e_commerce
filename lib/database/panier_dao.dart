import 'package:sqflite/sqflite.dart';
import 'app_database.dart';
import '../models/panier_produit_entity.dart';

class PanierDao {
  Future<void> insertProduit(PanierProduitEntity produit) async {
    final db = await AppDatabase.database;
    await db.insert(
      'panier_produit',
      produit.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<PanierProduitEntity>> getProduits(String panierId) async {
    final db = await AppDatabase.database;
    final maps = await db.query(
      'panier_produit',
      where: 'panier_id = ?',
      whereArgs: [panierId],
    );

    return maps.map((e) => PanierProduitEntity.fromMap(e)).toList();
  }

  Future<void> deleteProduit(String id) async {
    final db = await AppDatabase.database;
    await db.delete('panier_produit', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearPanier(String panierId) async {
    final db = await AppDatabase.database;
    await db.delete(
      'panier_produit',
      where: 'panier_id = ?',
      whereArgs: [panierId],
    );
  }
}
