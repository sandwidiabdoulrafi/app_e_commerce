import 'Produit.dart';

class Panier {
  final String id;
  final List<Produit> _produits;
  final DateTime createdAt;

  Panier({required this.id, List<Produit>? produits, DateTime? createdAt,})
    :  createdAt = createdAt ?? DateTime.now(),
    _produits = produits ?? [];

  // getter
  List<Produit> get produits => _produits;

  // Ajouter un produit
  void ajouterProduit(Produit produit) {
    final index = _produits.indexWhere((p) => p.id == produit.id);

    if (index != -1) {
      _produits[index].ajouterQuantite(produit.quantite);
    } else {
      _produits.add(produit);
    }
  }

  // Retirer produit
  void removeProduit(String produitId, [int quantite = 1]) {
    final index = _produits.indexWhere((p) => p.id == produitId);

    if (index != -1) {
      if (_produits[index].quantite > quantite) {
        _produits[index].retirerQuantite(quantite);
      } else {
        _produits.removeAt(index);
      }
    }
  }

  // Total prix
  double get total {
    double somme = 0;
    for (var p in _produits) {
      somme += p.price * p.quantite;
    }
    return somme;
  }

  // Total quantité
  int get totalQuantite {
    int qte = 0;
    for (var p in _produits) {
      qte += p.quantite;
    }
    return qte;
  }

  void viderPanier() {
    _produits.clear();
  }

  @override
  String toString() {
    return 'Panier(id: $id, produits: $_produits, total: $total)';
  }
}
