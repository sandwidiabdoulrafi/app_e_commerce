class Produit {
  // Attributs privés (underscore)
  String _id;
  String _name;
  String _categorie;
  String _description;
  double _price;
  String _imageUrl;
  int _quantite;

  // Constructeur
  Produit({
    required String id,
    required String name,
    required String categorie,
    required String description,
    required double price,
    required String imageUrl,
    required int quantite,
  })  : _id = id,
        _name = name,
        _categorie = categorie,
        _description = description,
        _price = price,
        _imageUrl = imageUrl,
        _quantite = quantite;

  // Getters
  String get id => _id;
  String get name => _name;
  String get categorie => _categorie;
  String get description => _description;
  double get price => _price;
  String get imageUrl => _imageUrl;
  int get quantite => _quantite;

  // Setters
  set id(String id) => _id = id;
  set name(String name) => _name = name;
  set categorie(String categorie) => _categorie = categorie;
  set description(String description) => _description = description;
  set price(double price) => _price = price;
  set imageUrl(String imageUrl) => _imageUrl = imageUrl;
  set quantite(int quantite) => _quantite = quantite;

  // Méthodes pratiques
  void ajouterQuantite(int qte) {
    _quantite += qte;
  }

  void retirerQuantite(int qte) {
    if (_quantite - qte >= 0) {
      _quantite -= qte;
    }
  }

  @override
  String toString() {
    return 'Produit(id: $_id, name: $_name, categorie: $_categorie, description: $_description, price: $_price, quantite: $_quantite)';
  }
}
