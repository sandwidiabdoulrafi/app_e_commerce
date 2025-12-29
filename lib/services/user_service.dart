import 'package:app_e_commerce/database/user_dao.dart';

import '../models/user.dart';

class UserService {
  final UserDao _userDao = UserDao();

  /// Créer un nouvel utilisateur
  Future<User> creerUtilisateur(User user) async {
    // Vérifie si l'utilisateur existe déjà
    final exists = await _userDao.userExists(user.email);
    if (exists) {
      throw Exception('Un utilisateur avec cet email existe déjà');
    }

    await _userDao.insertUser(user);
    return user;
  }

  /// Insérer un utilisateur s'il n'existe pas, sinon retourner l'utilisateur existant
  Future<User> insererOuRetourner(User user) async {
    return await _userDao.insertIfNotExistElseReturnUser(user);
  }

  /// Authentification utilisateur
  Future<User?> authentifier(String email, String password) async {
    return await _userDao.authenticate(email, password);
  }

  /// Récupérer un utilisateur par ID
  Future<User?> getUtilisateurParId(String id) async {
    return await _userDao.getUserById(id);
  }

  /// Récupérer un utilisateur par email
  Future<User?> getUtilisateurParEmail(String email) async {
    return await _userDao.getUserByEmail(email);
  }

  /// Mettre à jour un utilisateur
  Future<void> mettreAJourUtilisateur(User user) async {
    await _userDao.updateUser(user);
  }

  /// Supprimer un utilisateur
  Future<void> supprimerUtilisateur(String id) async {
    await _userDao.deleteUser(id);
  }

  /// Mettre à jour le mot de passe d'un utilisateur
  Future<void> changerMotDePasse(String userId, String nouveauMotDePasse) async {
    await _userDao.updatePassword(userId, nouveauMotDePasse);
  }
}
