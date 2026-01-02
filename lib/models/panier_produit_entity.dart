import 'package:app_e_commerce/models/produit.dart';

class PanierProduitEntity {
  final String id;
  final String panierId;
  final String produitId;
  final String name;
  final String description;
  final String categorie;
  final double price;
  final String imageUrl;
  final int quantite;
  final double note;

  PanierProduitEntity({
    required this.id,
    required this.panierId,
    required this.produitId,
    required this.name,
    required this.categorie,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.quantite,
    required this.note,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'panier_id': panierId,
    'produit_id': produitId,
    'name': name,
    'categorie': categorie,
    'description': description,
    'price': price,
    'imageUrl': imageUrl,
    'quantite': quantite,
    'note': note,
  };

  factory PanierProduitEntity.fromMap(Map<String, dynamic> map) {
    return PanierProduitEntity(
      id: map['id']?.toString() ?? '',
      panierId: map['panier_id']?.toString() ?? '',
      produitId: map['produit_id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      categorie: map['categorie']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: map['imageUrl']?.toString() ?? '',
      quantite: map['quantite'] is int
          ? map['quantite']
          : int.tryParse(map['quantite']?.toString() ?? '1') ?? 1,
      note: (map['note'] as num?)?.toDouble() ?? 0.0,
    );
  }
  PanierProduitEntity copyWith({
    String? id,
    String? panierId,
    String? produitId,
    String? name,
    String? categorie,
    String? description,
    double? price,
    String? imageUrl,
    int? quantite,
    double? note,
  }) {
    return PanierProduitEntity(
      id: id ?? this.id,
      panierId: panierId ?? this.panierId,
      produitId: produitId ?? this.produitId,
      name: name ?? this.name,
      categorie: categorie ?? this.categorie,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      quantite: quantite ?? this.quantite,
      note: note ?? this.note,
    );
  }
}

/// Extension pour convertir PanierProduitEntity en Produit
extension PanierProduitExtension on PanierProduitEntity {
  Produit toProduit() {
    return Produit(
      id: produitId,
      name: name,
      description: description,
      categorie: categorie,
      price: price,
      imageUrl: imageUrl,
      quantite: quantite,
      note: note,
    );
  }
}
