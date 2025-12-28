import 'package:flutter/material.dart';
import 'package:app_e_commerce/models/produit.dart';
import 'package:app_e_commerce/services/panier_service.dart';

class CartItemWidget extends StatefulWidget {
  final Produit produit;
  final VoidCallback onUpdate;

  const CartItemWidget({
    super.key,
    required this.produit,
    required this.onUpdate,
  });

  @override
  State<CartItemWidget> createState() => _CartItemWidgetState();
}

class _CartItemWidgetState extends State<CartItemWidget> {
  final PanierService _panierService = PanierService();
  bool _loading = false;

  Future<void> _incrementer() async {
    if (_loading) return;

    setState(() => _loading = true);

    try {
      final nouvelleQuantite = widget.produit.quantite + 1;
      final produitMaj = widget.produit.copyWith(quantite: nouvelleQuantite);
      await _panierService.mettreAJourQuantite(produitMaj, nouvelleQuantite);
      widget.onUpdate();
    } catch (e) {
      _afficherMessage('Erreur lors de la mise à jour');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _decrementer() async {
    if (_loading) return;

    if (widget.produit.quantite <= 1) {
      _confirmerSuppression();
      return;
    }

    setState(() => _loading = true);

    try {
      final nouvelleQuantite = widget.produit.quantite - 1;
      final produitMaj = widget.produit.copyWith(quantite: nouvelleQuantite);
      await _panierService.mettreAJourQuantite(produitMaj, nouvelleQuantite);
      widget.onUpdate();
    } catch (e) {
      _afficherMessage('Erreur lors de la mise à jour');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _confirmerSuppression() async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer du panier'),
        content: Text(
          'Voulez-vous retirer "${widget.produit.name}" du panier ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirme == true) {
      await _supprimer();
    }
  }

  Future<void> _supprimer() async {
    setState(() => _loading = true);

    try {
      await _panierService.supprimerDuPanier(widget.produit.id);
      widget.onUpdate();
      _afficherMessage('Produit retiré du panier');
    } catch (e) {
      _afficherMessage('Erreur lors de la suppression');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _afficherMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = widget.produit.price * widget.produit.quantite;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Image du produit
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                widget.produit.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported, size: 40),
                  );
                },
              ),
            ),

            const SizedBox(width: 12),

            // Informations du produit
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.produit.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.produit.price} FCFA',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Sélecteur de quantité
                  Row(
                    children: [
                      // Bouton -
                      _BoutonQuantite(
                        icon: Icons.remove,
                        onPressed: _loading ? null : _decrementer,
                      ),

                      // Quantité
                      Container(
                        width: 40,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          border: Border.symmetric(
                            horizontal: BorderSide(color: theme.dividerColor),
                          ),
                        ),
                        child: Text(
                          widget.produit.quantite.toString(),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      // Bouton +
                      _BoutonQuantite(
                        icon: Icons.add,
                        onPressed: _loading ? null : _incrementer,
                      ),

                      const Spacer(),

                      // Bouton supprimer
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: _loading ? null : _confirmerSuppression,
                        tooltip: 'Supprimer',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BoutonQuantite extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _BoutonQuantite({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(6),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            icon,
            size: 18,
            color: onPressed != null ? theme.primaryColor : Colors.grey,
          ),
        ),
      ),
    );
  }
}

