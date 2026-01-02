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

  Future<void> updateCommande(Commande commande) async {
    final db = await AppDatabase.database;
    await db.update(
      'commande',
      commande.toMap(),
      where: 'id = ?',
      whereArgs: [commande.id],
    );
  }

  Future<List<Map<String, dynamic>>> getCommandesByClientId(
    String clientId,
  ) async {
    final db = await AppDatabase.database;
    return db.query(
      'commande',
      where: 'client_id = ?',
      whereArgs: [clientId],
      orderBy: 'date DESC',
    );
  }

  Future<Map<String, dynamic>?> getCommandeById(String id) async {
    final db = await AppDatabase.database;
    final maps = await db.query(
      'commande',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return maps.isNotEmpty ? maps.first : null;
  }

  Future<void> updateStatut(String id, String statut) async {
    final db = await AppDatabase.database;
    await db.update(
      'commande',
      {'statut': statut},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateTotal(String id, double total) async {
    final db = await AppDatabase.database;
    await db.update(
      'commande',
      {'total': total},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Supprimer une commande
  Future<void> deleteCommande(String id) async {
    final db = await AppDatabase.database;
    await db.delete('commande', where: 'id = ?', whereArgs: [id]);
  }
}
