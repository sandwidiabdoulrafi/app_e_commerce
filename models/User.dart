class User {
  // Attributs privés
  String _id;
  String _nom;
  String _prenom;
  String _email;
  String _telephone;
  String _motDePasse;

  // Constructeur
  User({
    required String id,
    required String nom,
    required String prenom,
    required String email,
    required String telephone,
    required String motDePasse,
  })  : _id = id,
        _nom = nom,
        _prenom = prenom,
        _email = email,
        _telephone = telephone,
        _motDePasse = motDePasse;

  // Getters
  String get id => _id;
  String get nom => _nom;
  String get prenom => _prenom;
  String get email => _email;
  String get telephone => _telephone;
  String get motDePasse => _motDePasse;

  // Setters
  set id(String value) => _id = value;
  set nom(String value) => _nom = value;
  set prenom(String value) => _prenom = value;
  set email(String value) => _email = value;
  set telephone(String value) => _telephone = value;
  set motDePasse(String value) => _motDePasse = value;

  // Méthodes utiles
  String getNomComplet() {
    return '$_prenom $_nom';
  }

  bool verifierMotDePasse(String mdp) {
    return _motDePasse == mdp;
  }

  @override
  String toString() {
    return 'User(id: $_id, nom: $_nom, prenom: $_prenom, email: $_email, telephone: $_telephone)';
  }
}
