import 'package:sqflite/sqflite.dart';
import 'package:app_e_commerce/database/app_database.dart';
import 'package:app_e_commerce/models/produit_commande_entity.dart';

class ProduitCommandeDao {
  Future<void> insertProduitCommande(ProduitCommandeEntity produit) async {
    final Database db = await AppDatabase.database;

    await db.insert(
      'produit_commande',
      produit.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteByCommande(String commandeId) async {
    final db = await AppDatabase.database;
    await db.delete(
      'produit_commande',
      where: 'commande_id = ?',
      whereArgs: [commandeId],
    );
  }

  Future<List<ProduitCommandeEntity>> getByCommande(String commandeId) async {
    final db = await AppDatabase.database;
    final maps = await db.query(
      'produit_commande',
      where: 'commande_id = ?',
      whereArgs: [commandeId],
    );

    return maps.map((e) => ProduitCommandeEntity.fromMap(e)).toList();
  }

  Future<void> deleteProduitCommande(String id) async {
    final db = await AppDatabase.database;
    await db.delete('produit_commande', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateQuantite(String id, int quantite) async {
    final db = await AppDatabase.database;
    await db.update(
      'produit_commande',
      {'quantite': quantite},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
