import 'package:flutter/material.dart';

class EmptyCartWidget extends StatelessWidget {
  final VoidCallback? onContinuerAchats;

  const EmptyCartWidget({
    super.key,
    this.onContinuerAchats,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icône panier vide
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                size: 100,
                color: theme.primaryColor.withOpacity(0.5),
              ),
            ),

            const SizedBox(height: 32),

            // Titre
            Text(
              'Votre panier est vide',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Message
            Text(
              'Ajoutez des articles à votre panier pour commencer vos achats',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 40),

            // Bouton continuer les achats
            if (onContinuerAchats != null)
              ElevatedButton.icon(
                onPressed: onContinuerAchats,
                icon: const Icon(Icons.shopping_bag_outlined),
                label: const Text('Continuer mes achats'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
