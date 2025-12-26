class User {
  // Attributs privés
  String _id;
  String _nom;
  String _prenom;
  String _email;
  String _telephone;
  String _motDePasse;
  String _imgProfile;

  // Constructeur
  User({
    required String id,
    required String nom,
    required String prenom,
    required String email,
    required String telephone,
    required String motDePasse,
    required String imgProfile,
  }) : _id = id,
        _nom = nom,
        _prenom = prenom,
        _email = email,
        _telephone = telephone,
        _motDePasse = motDePasse,
        _imgProfile = imgProfile;

  // Getters
  String get id => _id;
  String get nom => _nom;
  String get prenom => _prenom;
  String get email => _email;
  String get telephone => _telephone;
  String get motDePasse => _motDePasse;
  String get imgProfile => _imgProfile;

  // Setters
  set id(String value) => _id = value;
  set nom(String value) => _nom = value;
  set prenom(String value) => _prenom = value;
  set email(String value) => _email = value;
  set telephone(String value) => _telephone = value;
  set motDePasse(String value) => _motDePasse = value;
  set imgProfile(String value) => _imgProfile = value;

  // Méthode copyWith pour créer une nouvelle instance avec des valeurs modifiées
  User copyWith({
    String? id,
    String? nom,
    String? prenom,
    String? email,
    String? telephone,
    String? motDePasse,
    String? imgProfile,
  }) {
    return User(
      id: id ?? this._id,
      nom: nom ?? this._nom,
      prenom: prenom ?? this._prenom,
      email: email ?? this._email,
      telephone: telephone ?? this._telephone,
      motDePasse: motDePasse ?? this._motDePasse,
      imgProfile: imgProfile ?? this._imgProfile,
    );
  }

  // Méthodes utiles
  String getNomComplet() {
    return '$_prenom $_nom';
  }

  bool verifierMotDePasse(String mdp) {
    return _motDePasse == mdp;
  }

  // Méthode pour convertir en Map (utile pour Firebase/Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': _id,
      'nom': _nom,
      'prenom': _prenom,
      'email': _email,
      'telephone': _telephone,
      'imgProfile': _imgProfile,
      // Note: motDePasse ne doit pas être stocké en clair dans la pratique
    };
  }

  // Méthode factory pour créer un User depuis une Map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      nom: map['nom'] ?? '',
      prenom: map['prenom'] ?? '',
      email: map['email'] ?? '',
      telephone: map['telephone'] ?? '',
      motDePasse: map['motDePasse'] ?? '', // À récupérer séparément pour la sécurité
      imgProfile: map['imgProfile'] ?? '',
    );
  }

  // Méthode pour créer un utilisateur vide (utile pour les formulaires)
  factory User.empty() {
    return User(
      id: '',
      nom: '',
      prenom: '',
      email: '',
      telephone: '',
      motDePasse: '',
      imgProfile: '',
    );
  }

  // Vérifie si l'utilisateur est vide
  bool isEmpty() {
    return _id.isEmpty && _email.isEmpty;
  }

  // Vérifie si l'utilisateur est valide
  bool isValid() {
    return _email.isNotEmpty && 
          _email.contains('@') && 
          _nom.isNotEmpty && 
          _prenom.isNotEmpty &&
           _motDePasse.length >= 6; // Exemple de validation de mot de passe
  }

  @override
  String toString() {
    return 'User(id: $_id, nom: $_nom, prenom: $_prenom, email: $_email, telephone: $_telephone)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other._id == _id;
  }

  @override
  int get hashCode => _id.hashCode;
}