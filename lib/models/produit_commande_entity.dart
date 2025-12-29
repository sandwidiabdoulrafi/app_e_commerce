class ProduitCommandeEntity {
  final String id;
  final String commandeId;
  final String panierId;
  final String produitId;
  final String name;
  final String description;
  final String categorie;
  final double price;
  final String imageUrl;
  final int quantite;
  final double note;

  ProduitCommandeEntity({
    required this.id,
    required this.commandeId,
  required this.panierId,
    required this.produitId,
    required this.name,
    required this.description,
    required this.categorie,
    required this.price,
    required this.imageUrl,
    required this.quantite,
    required this.note,
});

  Map<String, dynamic> toMap() => {
    'id': id,
    'commande_id': commandeId,
    'panier_id': panierId,
    'produit_id': produitId,
    'name': name,
    'description': description,
    'categorie': categorie,
    'price': price,
    'image_url': imageUrl,
    'quantite': quantite,
    'note': note,
  };

  factory ProduitCommandeEntity.fromMap(Map<String, dynamic> map) {
    return ProduitCommandeEntity(
      id: map['id'],
      commandeId: map['commande_id'],
      panierId: map['panier_id'],
      produitId: map['produit_id'],
      name: map['name'],
      description: map['description'],
      categorie: map['categorie'],
      price: (map['price'] as num).toDouble(),
      imageUrl: map['image_url'],
      quantite: map['quantite'],
      note: (map['note'] as num).toDouble(),
    );
  }

  // ProduitCommandeEntity copyWith({
  //   String? id,
  //   String? commandeId,
  //   String? produitId,
  //   String? name,
  //   String? categorie,
  //   String? description,
  //   double? price,
  //   String? imageUrl,
  //   int? quantite,
  //   double? note,
  // }) {
  //   return ProduitCommandeEntity(
  //     id: id ?? this.id,
  //     commandeId: commandeId?? this.commandeId,
  //     produitId: produitId ?? this.produitId,
  //     name: name ?? this.name,
  //     categorie: categorie ?? this.categorie,
  //     description: description ?? this.description,
  //     price: price ?? this.price,
  //     imageUrl: imageUrl ?? this.imageUrl,
  //     quantite: quantite ?? this.quantite,
  //     note: note ?? this.note,
  //   );
  // }
}
