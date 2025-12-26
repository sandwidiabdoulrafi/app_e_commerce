class PanierProduitEntity {
  final String id;
  final String panierId;
  final String produitId;
  final String name;
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
        'price': price,
        'imageUrl': imageUrl,
        'quantite': quantite,
        'note': note,
      };

  factory PanierProduitEntity.fromMap(Map<String, dynamic> map) {
    return PanierProduitEntity(
      id: map['id'],
      panierId: map['panier_id'],
      produitId: map['produit_id'],
      name: map['name'],
      categorie: map['categorie'],
      price: map['price'],
      imageUrl: map['imageUrl'],
      quantite: map['quantite'],
      note: map['note'],
    );
  }
}
