import 'package:app_e_commerce/models/user.dart';
import 'package:app_e_commerce/services/user_service.dart';
import 'package:app_e_commerce/widgets/panier/cart_item_widget.dart';
import 'package:app_e_commerce/widgets/panier/cart_summary_widget.dart';
import 'package:app_e_commerce/widgets/panier/empty_cart_widget.dart';

import 'package:flutter/material.dart';
import 'package:app_e_commerce/models/panier_produit_entity.dart';
import 'package:app_e_commerce/services/panier_service.dart';
import 'package:app_e_commerce/services/commade_service.dart';

class PanierScreen extends StatefulWidget {
  final VoidCallback? onRetourMarketplace; // ← AJOUTÉ

  const PanierScreen({
    super.key,
    this.onRetourMarketplace, // ← AJOUTÉ
  });

  @override
  State<PanierScreen> createState() => _PanierScreenState();
}

class _PanierScreenState extends State<PanierScreen> {
  final PanierService _panierService = PanierService();
  late CommandeService commandeService = CommandeService();
  List<PanierProduitEntity> _produitsPanier = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _chargerPanier();
  }

  Future<void> _chargerPanier() async {
    setState(() => _loading = true);

    try {
      final List<PanierProduitEntity> panierProduits = await _panierService
          .getPanier();

      if (mounted) {
        setState(() {
          _produitsPanier = panierProduits;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        _afficherMessage('Erreur lors du chargement du panier');
      }
    }
  }

  Future<void> _viderPanier() async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Vider le panier'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer tous les articles du panier ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Vider'),
          ),
        ],
      ),
    );

    if (confirme == true) {
      try {
        await _panierService.viderPanier();
        await _chargerPanier();
        _afficherMessage('Panier vidé avec succès');
      } catch (e) {
        _afficherMessage('Erreur lors de la suppression');
      }
    }
  }

  Future<void> _passerCommande() async {
    if (_produitsPanier.isEmpty) {
      _afficherMessage('Votre panier est vide');
      return;
    }

    try {
      final User? client = await UserService().getUtilisateurParId('12345');
      if (client == null) {
        _afficherMessage('Utilisateur non trouvé. Veuillez vous connecter.');
        return;
      }

      final panier = await _panierService.getPanierComplet();

      await commandeService.creerCommandeDepuisPanier(
        client: client,
        panier: panier,
      );

      await _panierService.viderPanier();
      setState(() => _produitsPanier.clear());

      _afficherMessage('Commande créée avec succès ✅');
    } catch (e) {
      _afficherMessage('Erreur lors de la création de la commande : $e');
    }
  }

  void _afficherMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Panier'),
        actions: [
          if (_produitsPanier.isNotEmpty)
            Center(
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_produitsPanier.length} article${_produitsPanier.length > 1 ? 's' : ''}',
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          if (_produitsPanier.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: _viderPanier,
              tooltip: 'Vider le panier',
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _produitsPanier.isEmpty
          ? EmptyCartWidget(
              onContinuerAchats: widget.onRetourMarketplace, // ← CORRIGÉ
            )
          : Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _chargerPanier,
                    child: ListView.builder(
                      padding: const EdgeInsets.only(top: 8, bottom: 16),
                      itemCount: _produitsPanier.length,
                      itemBuilder: (context, index) {
                        final produit = _produitsPanier[index];
                        return CartItemWidget(
                          produit: produit,
                          onUpdate: _chargerPanier,
                        );
                      },
                    ),
                  ),
                ),
                CartSummaryWidget(
                  produits: _produitsPanier,
                  onCommander: _passerCommande,
                ),
              ],
            ),
    );
  }
}
