import 'Produit.dart';

class Panier {
  final List<Produit> _produits = [];

  //getters
  List<Produit> get produits => produits;

  //ajouter un produit au panier

  void ajouterProduit(Produit produit) {
    // verifier si le produit est deja dans le panier

    final index = _produits.indexWhere((p) => p.id == produit.id);

    if (index != -1) {
      //augmenter le produit
      this._produits[index].ajouterQuantite(produit.quantite);
    } else {
      // sinon  ajouter le produit
      this._produits.add(produit);
    }
  }

  // retirer un produit panier
  void removeProduit(String produitId, [int quantite = 1]) {
    final index = this._produits.indexWhere((p) => p.id == produitId);
    if (index != -1) {
      if (_produits[index].quantite > quantite) {
        _produits[index].retirerQuantite(quantite);
      } else {
        _produits.removeAt(index);
      }
    }

  }

    double get total {
    double somme = 0;
    for (var produit in _produits) {
      somme += produit.price * produit.quantite;
    }
    return somme;
  }

    // Vider le panier
  void viderPanier() {
    _produits.clear();
  }


    @override
    String toString() {
      return 'Panier(produits: $_produits, total: $total)';
    }


}
