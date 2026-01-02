import 'package:app_e_commerce/models/produit_commande_entity.dart';
import 'package:uuid/uuid.dart';
import 'package:app_e_commerce/models/user.dart';
import 'Panier.dart';

class Commande {
  String id;
  User client;
  List<ProduitCommandeEntity> produits;
  int date;
  String statut;

  Commande({
    required this.id,
    required this.client,
    required this.produits,
    int? date,
    this.statut = 'en cours',
  }) : date = date ?? DateTime.now().millisecondsSinceEpoch;

  /// Total de la commande
  double get total {
    return produits.fold(0, (somme, p) => somme + (p.price * p.quantite));
  }

  /// Ajouter les produits du panier à la commande
  void ajouterPanierDansCommande(Panier panier) {
    produits.clear();
    produits.addAll(
      panier.produits.map(
        (p) => ProduitCommandeEntity(
          id: const Uuid().v4(),
          commandeId: id,
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
      ),
    );
  }

  /// Vider la commande
  void viderCommande() {
    produits.clear();
  }

  /// Conversion DB
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'client_id': client.id,
      'date': date,
      'statut': statut,
      'total': total,
    };
  }

  factory Commande.fromMap(
    Map<String, dynamic> map, {
    required User client,
    List<ProduitCommandeEntity>? produits,
  }) {
    final dynamic rawDate = map['date'];
    final int parsedDate = rawDate is int
        ? rawDate
        : (int.tryParse(rawDate?.toString() ?? '') ??
              (DateTime.tryParse(
                    rawDate?.toString() ?? '',
                  )?.millisecondsSinceEpoch ??
                  DateTime.now().millisecondsSinceEpoch));

    return Commande(
      id: map['id']?.toString() ?? '',
      client: client,
      produits: produits ?? <ProduitCommandeEntity>[],
      date: parsedDate,
      statut: map['statut']?.toString() ?? 'en cours',
    );
  }

  @override
  String toString() {
    return 'Commande(id: $id, client: ${client.getNomComplet()}, total: $total, statut: $statut)';
  }
}
