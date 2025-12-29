import 'package:app_e_commerce/database/ProduitCommandeDao.dart';
import 'package:uuid/uuid.dart';
import '../database/commande_dao.dart';
import '../models/Commande.dart';
import '../models/produit_commande_entity.dart';
import '../models/Panier.dart';
import '../models/user.dart';

class CommandeService {
  final CommandeDao _commandeDao = CommandeDao();
  final ProduitCommandeDao _produitCommandeDao = ProduitCommandeDao();

  final Uuid _uuid = const Uuid();

  Future<Commande> creerCommandeDepuisPanier({
    required User client,
    required Panier panier,
  }) async {
    if (panier.produits.isEmpty) {
      throw Exception('Le panier est vide');
    }

    final commandeId = _uuid.v4();

    final commande = Commande(
      id: commandeId,
      client: client,
      produits: [],
    );

    // 1️⃣ Sauvegarde commande
    await _commandeDao.insertCommande(commande);

    // 2️⃣ Sauvegarde produits
    for (final p in panier.produits) {
      final produitCommande = ProduitCommandeEntity(
        id: _uuid.v4(),
        commandeId: commandeId,
        panierId: panier.id,
        produitId: p.id,
        name: p.name,
        description: p.description,
        categorie: p.categorie,
        price: p.price,
        imageUrl: p.imageUrl,
        quantite: p.quantite,
        note: p.note,
      );

      await _produitCommandeDao.insertProduitCommande(produitCommande);
    }

    return commande;
  }
}
