import 'package:flutter/material.dart';
import 'package:app_e_commerce/models/produit.dart';
import 'package:app_e_commerce/services/panier_service.dart';

class DetailProduit extends StatefulWidget {
  final Produit produit;

  const DetailProduit({super.key, required this.produit});

  @override
  State<DetailProduit> createState() => _DetailProduitState();
}

class _DetailProduitState extends State<DetailProduit> {
  final PanierService _panierService = PanierService();
  bool _estDansPanier = false;
  bool _loading = true;
  bool _ajoutEnCours = false;
  int _quantiteDansPanier = 0;
  int _quantiteChoisie = 1;

  @override
  void initState() {
    super.initState();
    _verifierPanier();
  }

  Future<void> _verifierPanier() async {
    try {
      final existe = await _panierService.produitExiste(widget.produit.id);
      if (existe) {
        final produitPanier = await _panierService.getProduit(
          widget.produit.id,
        );
        if (produitPanier != null) {
          _quantiteDansPanier = produitPanier.quantite;
        }
      }

      if (mounted) {
        setState(() {
          _estDansPanier = existe;
          _quantiteChoisie = _quantiteDansPanier > 0 ? _quantiteDansPanier : 1;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        _afficherErreur('Erreur lors de la vérification du panier');
      }
    }
  }

  Future<void> _ajouterAuPanier() async {
    if (_ajoutEnCours) return;

    setState(() => _ajoutEnCours = true);

    try {
      // Si le produit n'est pas encore dans le panier
      if (!_estDansPanier) {
        // Créer une copie avec la quantité choisie (1 par défaut)
        final produitAvecQuantite = widget.produit.copyWith(
          quantite: _quantiteChoisie,
        );
        await _panierService.ajouterOuIncrementer(produitAvecQuantite);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.produit.name} ajouté au panier'),
            duration: const Duration(seconds: 2),
          ),
        );
      } 
      // Si le produit est déjà dans le panier, on met à jour la quantité
      else {
        await _mettreAJourQuantite(_quantiteChoisie);
      }
      
      await _verifierPanier();
    } catch (e) {
      _afficherErreur('Impossible d\'ajouter le produit au panier');
    } finally {
      if (mounted) {
        setState(() => _ajoutEnCours = false);
      }
    }
  }

  Future<void> _mettreAJourQuantite(int nouvelleQuantite) async {
    if (nouvelleQuantite < 1 || nouvelleQuantite > widget.produit.quantite) {
      return;
    }

    try {
      // Créer une copie du produit avec la nouvelle quantité
      final produitMisAJour = widget.produit.copyWith(
        quantite: nouvelleQuantite,
      );
      
      if (nouvelleQuantite == 0) {
        await _panierService.supprimerDuPanier(widget.produit.id);
      } else {

        await _panierService.mettreAJourQuantite(produitMisAJour, nouvelleQuantite);
      }
      
      await _verifierPanier();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Quantité mise à jour'),
          duration: Duration(seconds: 1),
        ),
      );
    } catch (e) {
      _afficherErreur('Erreur lors de la mise à jour de la quantité');
    }
  }

  void _incrementerQuantite() {
    if (_quantiteChoisie < widget.produit.quantite) {
      final nouvelleQuantite = _quantiteChoisie + 1;
      setState(() => _quantiteChoisie = nouvelleQuantite);
      // if (_estDansPanier) {
      //   _mettreAJourQuantite(nouvelleQuantite);
      // }
    }
  }

  void _decrementerQuantite() {
    if (_quantiteChoisie > 1) {
      final nouvelleQuantite = _quantiteChoisie - 1;
      setState(() => _quantiteChoisie = nouvelleQuantite);
      // if (_estDansPanier) {
      //   _mettreAJourQuantite(nouvelleQuantite);
      // }
    }
  }

  void _afficherErreur(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message), 
        backgroundColor: Colors.red
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final produit = widget.produit;
    final theme = Theme.of(context);
    final total = _quantiteChoisie * produit.price;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          produit.name, 
          maxLines: 1, 
          overflow: TextOverflow.ellipsis
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image du produit
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Image.network(
                        produit.imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: theme.colorScheme.surfaceVariant,
                            child: const Center(
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                size: 64,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Titre et note
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          produit.name,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Chip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              produit.note.toStringAsFixed(1),
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.white,
                            ),
                          ],
                        ),
                        backgroundColor: theme.primaryColor,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Description
                  Text(
                    produit.description,
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                  ),

                  const SizedBox(height: 24),

                  // Informations de prix et stock
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Prix', style: theme.textTheme.bodyLarge),
                            Text(
                              '${produit.price} FCFA',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.primaryColor,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Stock disponible',
                              style: theme.textTheme.bodyLarge,
                            ),
                            Text(
                              '${produit.quantite} unités',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: produit.quantite > 0
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Sélecteur de quantité
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _estDansPanier 
                            ? 'Quantité dans le panier' 
                            : 'Choisir la quantité',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Bouton moins
                            _BoutonQuantite(
                              icon: Icons.remove,
                              onPressed: _decrementerQuantite,
                              disabled: _quantiteChoisie <= 1,
                            ),

                            // Affichage de la quantité
                            Container(
                              width: 80,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: theme.dividerColor),
                              ),
                              child: Text(
                                _quantiteChoisie.toString(),
                                textAlign: TextAlign.center,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            // Bouton plus
                            _BoutonQuantite(
                              icon: Icons.add,
                              onPressed: _incrementerQuantite,
                              disabled: _quantiteChoisie >= produit.quantite,
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Calcul du total
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total :',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '$_quantiteChoisie × ${produit.price} FCFA = ${total} FCFA',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: theme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Indication de stock
                        Text(
                          'Stock disponible : ${produit.quantite} unités',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Bouton d'ajout/mise à jour du panier
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: produit.quantite > 0 ? _ajouterAuPanier : null,
                      icon: _ajoutEnCours
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Icon(
                              _estDansPanier
                                  ? Icons.shopping_cart_checkout
                                  : Icons.shopping_cart_outlined,
                            ),
                      label: _ajoutEnCours
                          ? const Text('Traitement en cours...')
                          : Text(
                              _estDansPanier
                                  ? 'Mettre à jour le panier'
                                  : produit.quantite > 0
                                      ? 'Ajouter au panier'
                                      : 'Rupture de stock',
                            ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        backgroundColor: produit.quantite > 0
                            ? theme.primaryColor
                            : Colors.grey,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
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
  final VoidCallback onPressed;
  final bool disabled;

  const _BoutonQuantite({
    required this.icon,
    required this.onPressed,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.only(
          topLeft: icon == Icons.remove ? const Radius.circular(8) : Radius.zero,
          bottomLeft: icon == Icons.remove ? const Radius.circular(8) : Radius.zero,
          topRight: icon == Icons.add ? const Radius.circular(8) : Radius.zero,
          bottomRight: icon == Icons.add ? const Radius.circular(8) : Radius.zero,
        ),
      ),
      child: IconButton(
        icon: Icon(
          icon, 
          color: disabled ? Colors.grey : theme.primaryColor
        ),
        onPressed: disabled ? null : onPressed,
        style: IconButton.styleFrom(
          shape: const RoundedRectangleBorder()
        ),
      ),
    );
  }
}