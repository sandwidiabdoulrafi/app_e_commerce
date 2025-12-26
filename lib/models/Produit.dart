
import 'dart:convert';
import 'package:flutter/services.dart';



class Produit {
  // Attributs privés (underscore)
  String _id;
  String _name;
  String _categorie;
  String _description;
  double _price;
  String _imageUrl;
  int _quantite;
  double _note;

  // Constructeur
  Produit({
    required String id,
    required String name,
    required String categorie,
    required String description,
    required double price,
    required String imageUrl,
    required int quantite,
    required double note
  })  : _id = id,
        _name = name,
        _categorie = categorie,
        _description = description,
        _price = price,
        _imageUrl = imageUrl,
        _quantite = quantite,
        _note = (note >= 0 && note<=5) ? note : 0.0;




  factory Produit.fromJson(Map<String, dynamic> json){
    return Produit(
      id: json['id'],
      name: json['name'],
      categorie: json['categorie'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'],
      quantite: json['quantite'],
      note: (json['note'] as num).toDouble(),
    );
  }

  Produit copyWith({
    String? id,
    String? name,
    String? categorie,
    double? price,
    String? imageUrl,
    String? description,
    double? note,
    int? quantite,
  }) {
    return Produit(
      id: id ?? this.id,
      name: name ?? this.name,
      categorie: categorie ?? this.categorie,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      note: note ?? this.note,
      quantite: quantite ?? this.quantite,
    );
  }





  // Getters
  String get id => _id;
  String get name => _name;
  String get categorie => _categorie;
  String get description => _description;
  double get price => _price;
  String get imageUrl => _imageUrl;
  int get quantite => _quantite;
  double get note => _note;

  // Setters
  set id(String id) => _id = id;
  set name(String name) => _name = name;
  set categorie(String categorie) => _categorie = categorie;
  set description(String description) => _description = description;
  set price(double price) => _price = price;
  set imageUrl(String imageUrl) => _imageUrl = imageUrl;

  set quantite(int value) {
    if (value >= 0) {
      _quantite = value;
    }
  }

  set note(double value) {
    if (value >= 0 && value <= 5) {
      _note = value;
    }
  }

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
    return 'Produit(id: $_id, name: $_name, categorie: $_categorie, description: $_description, price: $_price, quantite: $_quantite, note: $_note)';
  }
}
