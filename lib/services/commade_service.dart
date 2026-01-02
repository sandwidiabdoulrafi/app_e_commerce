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
    final numero = await _commandeDao.getNextNumero();

    final produitsCommande = panier.produits
        .map(
          (p) => ProduitCommandeEntity(
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
          ),
        )
        .toList();

    final commande = Commande(
      id: commandeId,
      numero: numero,
      client: client,
      produits: produitsCommande,
    );

    await _commandeDao.insertCommande(commande);

    for (final produitCommande in produitsCommande) {
      await _produitCommandeDao.insertProduitCommande(produitCommande);
    }

    return commande;
  }

  Future<List<Commande>> getCommandesPourClient({required User client}) async {
    final commandeMaps = await _commandeDao.getCommandesByClientId(client.id);
    final List<Commande> commandes = [];

    for (final map in commandeMaps) {
      final commandeId = map['id']?.toString() ?? '';
      final produits = await _produitCommandeDao.getByCommande(commandeId);
      commandes.add(Commande.fromMap(map, client: client, produits: produits));
    }

    return commandes;
  }

  Future<Commande?> getCommandeDetail({
    required String commandeId,
    required User client,
  }) async {
    final map = await _commandeDao.getCommandeById(commandeId);
    if (map == null) return null;
    final produits = await _produitCommandeDao.getByCommande(commandeId);
    return Commande.fromMap(map, client: client, produits: produits);
  }

  Future<void> annulerCommande({required String commandeId}) async {
    await _commandeDao.updateStatut(commandeId, 'annulée');
  }

  Future<void> supprimerCommande({required String commandeId}) async {
    await _produitCommandeDao.deleteByCommande(commandeId);
    await _commandeDao.deleteCommande(commandeId);
  }

  Future<void> retirerProduitDeCommande({
    required String commandeId,
    required String produitCommandeId,
  }) async {
    await _produitCommandeDao.deleteProduitCommande(produitCommandeId);
    await _recalculerTotalOuSupprimer(commandeId: commandeId);
  }

  Future<void> changerQuantiteProduit({
    required String commandeId,
    required String produitCommandeId,
    required int nouvelleQuantite,
  }) async {
    if (nouvelleQuantite < 1) {
      await retirerProduitDeCommande(
        commandeId: commandeId,
        produitCommandeId: produitCommandeId,
      );
      return;
    }

    await _produitCommandeDao.updateQuantite(
      produitCommandeId,
      nouvelleQuantite,
    );
    await _recalculerTotalOuSupprimer(commandeId: commandeId);
  }

  Future<void> _recalculerTotalOuSupprimer({required String commandeId}) async {
    final produits = await _produitCommandeDao.getByCommande(commandeId);
    if (produits.isEmpty) {
      await supprimerCommande(commandeId: commandeId);
      return;
    }

    final total = produits.fold<double>(
      0.0,
      (somme, p) => somme + (p.price * p.quantite),
    );
    await _commandeDao.updateTotal(commandeId, total);
  }
}
