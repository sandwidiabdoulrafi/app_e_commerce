import 'package:sqflite/sqflite.dart';
import 'package:app_e_commerce/database/app_database.dart';
import 'package:app_e_commerce/models/produit_commande_entity.dart';

class ProduitCommandeDao {

  Future<void> insertProduitCommande(
    ProduitCommandeEntity produit,
  ) async {
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
}
