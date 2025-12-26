import 'package:flutter/material.dart';
import 'package:app_e_commerce/models/produit.dart';
import 'package:flutter/services.dart';
import 'package:app_e_commerce/widgets/marketplace/itemsProduit.dart';
import 'dart:convert';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  final List<String> listCategorie = [
    "Tous",
    "Téléphones",
    "Ordinateurs",
    "Accessoires",
  ];

  List<Produit> produits = [];
  String selectedCategorie = 'Tous';
  String recherche = "";

  @override
  void initState() {
    super.initState();
    fetchProduits();
  }

  Future<void> fetchProduits() async {
    try {
      final String response = await rootBundle.loadString("data/produits_json.json");
      final List data = json.decode(response);
      setState(() {
        produits = data.map((produit) => Produit.fromJson(produit)).toList();
      });
      print("✅ Produits chargés : ${produits.length}");
    } catch (e) {
      print("❌ Erreur lors du chargement des produits : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filtrage par catégorie et recherche
    final List<Produit> produitsFiltres = produits.where((produit) {
      final bool categorieOk = selectedCategorie == 'Tous' || produit.categorie == selectedCategorie;
      final bool rechercheOk = produit.name.toLowerCase().contains(recherche.toLowerCase());
      return categorieOk && rechercheOk;
    }).toList();



    return Scaffold(
      appBar: AppBar(title: const Text('Marketplace')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Barre de recherche
            TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher un produit...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {},
                ),
              ),
              onChanged: (val) {
                setState(() {
                  recherche = val;
                });
              },
            ),

            const SizedBox(height: 10),

            // Filtre par catégorie
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: listCategorie.map((categorie) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(categorie),
                      selected: selectedCategorie == categorie,
                      onSelected: (selected) {
                        setState(() {
                          selectedCategorie = categorie;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 10),

            // Affichage des produits
            Expanded(
              child: produitsFiltres.isEmpty
                  ? const Center(
                      child: Text(
                        "Aucun produit trouvé",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(8),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // 2 produits par ligne
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 0.65, // Ajuste selon la taille des cartes
                      ),
                      itemCount: produitsFiltres.length,
                      itemBuilder: (context, index) {
                        return ItemsProduit(produit: produitsFiltres[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
