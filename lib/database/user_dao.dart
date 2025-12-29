import 'package:app_e_commerce/database/app_database.dart';
import 'package:app_e_commerce/models/user.dart';
import 'package:sqflite/sqflite.dart';

class UserDao {
  // Insérer un utilisateur
  Future<void> insertUser(User user) async {
    final db = await AppDatabase.database;

    // Vérifier si l'utilisateur existe déjà
    final existingUsers = await db.query(
      'users',
      where: 'email = ? OR telephone = ?',
      whereArgs: [user.email, user.telephone],
    );

    if (existingUsers.isNotEmpty) {
      throw Exception('Un utilisateur avec cet email ou téléphone existe déjà');
    }

    // Insérer le nouvel utilisateur
    await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Récupérer un utilisateur par ID
  Future<User?> getUserById(String id) async {
    final db = await AppDatabase.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  // Récupérer un utilisateur par email
  Future<User?> getUserByEmail(String email) async {
    final db = await AppDatabase.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  // Mettre à jour un utilisateur
  Future<int> updateUser(User user) async {
    final db = await AppDatabase.database;

    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // Supprimer un utilisateur
  Future<int> deleteUser(String id) async {
    final db = await AppDatabase.database;

    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  // inserer si l'user 'existe pas mais s'il existe on le retoure
Future<User> insertIfNotExistElseReturnUser(User user) async {
  try {
    await insertUser(user);
    return user;
  } catch (e) {
    // L'utilisateur existe déjà
    return user;
  }
}


  // Vérifier si un utilisateur existe
  Future<bool> userExists(String email) async {
    final db = await AppDatabase.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );

    return maps.isNotEmpty;
  }

  Future<User?> authenticate(String email, String password) async {
    final db = await AppDatabase.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ? AND motDePasse = ?',
      whereArgs: [email, password],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  // Mettre à jour le mot de passe
  Future<int> updatePassword(String userId, String newPassword) async {
    final db = await AppDatabase.database;

    return await db.rawUpdate('UPDATE users SET motDePasse = ? WHERE id = ?', [
      newPassword,
      userId,
    ]);
  }
}
