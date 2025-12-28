import 'package:flutter/material.dart';
import 'package:app_e_commerce/models/produit.dart';

class CartSummaryWidget extends StatelessWidget {
  final List<Produit> produits;
  final VoidCallback onCommander;

  const CartSummaryWidget({
    super.key,
    required this.produits,
    required this.onCommander,
  });

  double get _sousTotal {
    return produits.fold(
      0.0,
      (total, produit) => total + (produit.price * produit.quantite),
    );
  }

  double get _fraisLivraison {
    // Livraison gratuite à partir de 50 000 FCFA
    return _sousTotal >= 50000 ? 0 : 2000;
  }

  double get _total {
    return _sousTotal + _fraisLivraison;
  }

  int get _nombreArticles {
    return produits.fold(
      0,
      (total, produit) => total + produit.quantite,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Nombre d'articles
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Articles ($_nombreArticles)',
                  style: theme.textTheme.bodyLarge,
                ),
                Text(
                  '${_sousTotal.toStringAsFixed(0)} FCFA',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Frais de livraison
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('Livraison'),
                    if (_fraisLivraison == 0)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'GRATUIT',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                Text(
                  _fraisLivraison == 0
                      ? 'GRATUIT'
                      : '${_fraisLivraison.toStringAsFixed(0)} FCFA',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: _fraisLivraison == 0 ? Colors.green : null,
                  ),
                ),
              ],
            ),

            // Message livraison gratuite
            if (_sousTotal < 50000 && _sousTotal > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.local_shipping_outlined,
                        size: 16,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Plus que ${(50000 - _sousTotal).toStringAsFixed(0)} FCFA pour la livraison gratuite !',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1),
            ),

            // Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_total.toStringAsFixed(0)} FCFA',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Bouton commander
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: produits.isEmpty ? null : onCommander,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shopping_bag_outlined),
                    const SizedBox(width: 8),
                    Text(
                      'Passer la commande',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}