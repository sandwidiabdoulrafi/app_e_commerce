import '../../models/produit.dart';
import '../../models/user.dart';

class Commande {
  // Attributs privés
  String _id;
  User _client;
  List<Produit> _produits;
  DateTime _date;
  String _statut; // par exemple: "en cours", "livrée", "annulée"

  // Constructeur
  Commande({
    required String id,
    required User client,
    required List<Produit> produits,
    DateTime? date,
    String statut = 'en cours',
  }) : _id = id,
        _client = client,
        _produits = produits,
        _date = date ?? DateTime.now(),
        _statut = statut;

  // Getters
  String get id => _id;
  User get client => _client;
  List<Produit> get produits => _produits;
  DateTime get date => _date;
  String get statut => _statut;

  // Setters
  set id(String value) => _id = value;
  set client(User value) => _client = value;
  set produits(List<Produit> value) => _produits = value;
  set date(DateTime value) => _date = value;
  set statut(String value) => _statut = value;

  // Méthode pour calculer le total
  double get total {
    double somme = 0;
    for (var produit in _produits) {
      somme += produit.price * produit.quantite;
    }
    return somme;
  }

  // Ajouter un produit à la commande
  void ajouterProduit(Produit produit) {
    final index = _produits.indexWhere((p) => p.id == produit.id);
    if (index != -1) {
      _produits[index].ajouterQuantite(produit.quantite);
    } else {
      _produits.add(produit);
    }
  }

  // Retirer un produit de la commande
  void retirerProduit(String produitId, [int quantite = 1]) {
    final index = _produits.indexWhere((p) => p.id == produitId);
    if (index != -1) {
      if (_produits[index].quantite > quantite) {
        _produits[index].retirerQuantite(quantite);
      } else {
        _produits.removeAt(index);
      }
    }
  }

  @override
  String toString() {
    return 'Commande(id: $_id, client: ${_client.getNomComplet()}, produits: $_produits, total: $total, statut: $_statut, date: $_date)';
  }
}

