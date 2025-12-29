import 'package:sqflite/sqflite.dart';
import 'package:app_e_commerce/database/app_database.dart';
import 'package:app_e_commerce/models/Commande.dart';

class CommandeDao {

  /// Insérer une commande
  Future<void> insertCommande(Commande commande) async {
    final Database db = await AppDatabase.database;

    await db.insert(
      'commande',
      commande.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  Future<void>insertProduit()async{

  }

  /// Supprimer une commande
  Future<void> deleteCommande(String id) async {
    final db = await AppDatabase.database;
    await db.delete(
      'commande',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
