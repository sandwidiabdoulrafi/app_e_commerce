import '../models/produit.dart';
import '../models/panier_produit_entity.dart';
import '../database/panier_dao.dart';

class PanierService {
  final PanierDao _dao = PanierDao();
  final String panierId = 'PANIER_1';

  /// Ajoute un produit au panier (nouveau)
  Future<void> ajouterAuPanier(Produit produit) async {
    final panierProduit = PanierProduitEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      panierId: panierId,
      produitId: produit.id,
      name: produit.name,
      categorie: produit.categorie,
      price: produit.price,
      imageUrl: produit.imageUrl,
      quantite: 1,
      note: produit.note,
    );

    await _dao.insertProduit(panierProduit);
  }

  /// Récupère tous les produits du panier
  Future<List<PanierProduitEntity>> getPanier() {
    return _dao.getProduits(panierId);
  }

  /// Récupère un produit spécifique du panier par ID
  Future<PanierProduitEntity?> getProduit(String produitId) async {
    final produits = await _dao.getProduits(panierId);
    try {
      return produits.firstWhere((p) => p.produitId == produitId);
    } catch (e) {
      return null; // Produit non trouvé
    }
  }


  /// Supprime un produit du panier
  Future<void> supprimerDuPanier(String produitId) async {
    await _dao.deleteProduit(produitId);
  }

  /// Met à jour la quantité d’un produit dans le panier
  Future<void> mettreAJourQuantite(Produit produit, int quantite) async {
    if (quantite < 1) {
      await supprimerDuPanier(produit.id);
      return;
    }

    final produitPanier = await getProduit(produit.id);
    if (produitPanier != null) {
      final updated = PanierProduitEntity(
        id: produitPanier.id,
        panierId: produitPanier.panierId,
        produitId: produitPanier.produitId,
        name: produitPanier.name,
        categorie: produitPanier.categorie,
        price: produitPanier.price,
        imageUrl: produitPanier.imageUrl,
        quantite: quantite,
        note: produitPanier.note,
      );

      await _dao.insertProduit(updated);
    }
  }

  /// Vide le panier complet
  Future<void> viderPanier() {
    return _dao.clearPanier(panierId);
  }

  /// Vérifie si un produit existe déjà dans le panier
  Future<bool> produitExiste(String produitId) async {
    final produits = await _dao.getProduits(panierId);
    return produits.any((p) => p.produitId == produitId);
  }

  /// Ajoute ou incrémente la quantité d’un produit
  Future<void> ajouterOuIncrementer(Produit produit) async {
    final existe = await produitExiste(produit.id);

    if (existe) {
      final produitPanier = (await _dao.getProduits(panierId))
          .firstWhere((p) => p.produitId == produit.id);

      final updated = PanierProduitEntity(
        id: produitPanier.id,
        panierId: produitPanier.panierId,
        produitId: produitPanier.produitId,
        name: produitPanier.name,
        categorie: produitPanier.categorie,
        price: produitPanier.price,
        imageUrl: produitPanier.imageUrl,
        quantite: produitPanier.quantite + 1,
        note: produitPanier.note,
      );

      await _dao.insertProduit(updated);
    } else {
      await ajouterAuPanier(produit);
    }
  }
}
