import 'package:flutter/material.dart';
import 'package:app_e_commerce/models/produit.dart';
import 'package:app_e_commerce/services/panier_service.dart';
import 'package:app_e_commerce/widgets/marketplace/detailProduit.dart';

class ItemsProduit extends StatefulWidget {
  final Produit produit;

  const ItemsProduit({super.key, required this.produit});

  @override
  State<ItemsProduit> createState() => _ItemsProduitState();
}

class _ItemsProduitState extends State<ItemsProduit> {
  final PanierService _panierService = PanierService();

  bool estDansPanier = false;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _verifierPanier();
  }

  /// Vérifie dans SQLite
  Future<void> _verifierPanier() async {
    final existe = await _panierService.produitExiste(widget.produit.id);

    if (mounted) {
      setState(() {
        estDansPanier = existe;
        loading = false;
      });
    }
  }

  /// Ajouter ou incrémenter
  Future<void> _onAjouter() async {
    await _panierService.ajouterOuIncrementer(widget.produit);
    await _verifierPanier();
  }

  @override
  Widget build(BuildContext context) {
    final produit = widget.produit;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🖼 Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: produit.imageUrl.isNotEmpty
                  ? Image.network(
                      produit.imageUrl,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      'assets/placeholderImage.jpg',
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
            ),

            const SizedBox(height: 8),

            Center(
              child: Text(
                produit.categorie.toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 6),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    produit.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text(
                      produit.note.toString(),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 6),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Stock : ${produit.quantite}",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  "${produit.price} FCFA",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // 🛒 Boutons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: estDansPanier
                          ? Colors.grey
                          : Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: loading ? null : _onAjouter,
                    icon: Icon(
                      estDansPanier ? Icons.check : Icons.shopping_cart,
                      size: 18,
                    ),
                    label: Text(
                      estDansPanier ? "Ajouté" : "Ajouter",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailProduit(produit: produit),
                        ),
                      );
                    },
                    icon: const Icon(Icons.visibility, size: 18),
                    label: const Text(
                      "Voir plus",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
