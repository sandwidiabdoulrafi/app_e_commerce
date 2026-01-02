import 'package:app_e_commerce/models/Commande.dart';
import 'package:app_e_commerce/models/produit_commande_entity.dart';
import 'package:app_e_commerce/models/user.dart';
import 'package:app_e_commerce/services/commade_service.dart';
import 'package:app_e_commerce/services/user_service.dart';
import 'package:flutter/material.dart';

class CommandeDetailScreen extends StatefulWidget {
  final String commandeId;

  const CommandeDetailScreen({super.key, required this.commandeId});

  @override
  State<CommandeDetailScreen> createState() => _CommandeDetailScreenState();
}

class _CommandeDetailScreenState extends State<CommandeDetailScreen> {
  final CommandeService _commandeService = CommandeService();
  final UserService _userService = UserService();

  late Future<Commande> _future;

  @override
  void initState() {
    super.initState();
    _future = _charger();
  }

  Future<Commande> _charger() async {
    final User? client = await _userService.getUtilisateurParId('12345');
    if (client == null) {
      throw Exception('Utilisateur non trouvé');
    }

    final commande = await _commandeService.getCommandeDetail(
      commandeId: widget.commandeId,
      client: client,
    );

    if (commande == null) {
      throw Exception('Commande introuvable');
    }

    return commande;
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _charger();
    });
    await _future;
  }

  String _formatDate(int epochMs) {
    final dt = DateTime.fromMillisecondsSinceEpoch(epochMs).toLocal();
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $hh:$mm';
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  Future<bool> _confirmer({
    required String titre,
    required String message,
  }) async {
    final res = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(titre),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
    return res == true;
  }

  Future<void> _annulerCommande() async {
    final ok = await _confirmer(
      titre: 'Annuler la commande',
      message: 'Voulez-vous annuler cette commande ?',
    );
    if (!ok) return;

    try {
      await _commandeService.annulerCommande(commandeId: widget.commandeId);
      _snack('Commande annulée');
      await _refresh();
    } catch (e) {
      _snack('Erreur: $e');
    }
  }

  Future<void> _supprimerCommande() async {
    final ok = await _confirmer(
      titre: 'Supprimer la commande',
      message: 'Supprimer définitivement cette commande ?',
    );
    if (!ok) return;

    try {
      await _commandeService.supprimerCommande(commandeId: widget.commandeId);
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      _snack('Erreur: $e');
    }
  }

  Future<void> _retirerProduit(ProduitCommandeEntity produit) async {
    final ok = await _confirmer(
      titre: 'Retirer le produit',
      message: 'Retirer "${produit.name}" de la commande ?',
    );
    if (!ok) return;

    try {
      await _commandeService.retirerProduitDeCommande(
        commandeId: widget.commandeId,
        produitCommandeId: produit.id,
      );

      await _refresh();
    } catch (e) {
      _snack('Erreur: $e');
    }
  }

  Future<void> _changerQuantite(
    ProduitCommandeEntity produit,
    int nouvelleQuantite,
  ) async {
    try {
      await _commandeService.changerQuantiteProduit(
        commandeId: widget.commandeId,
        produitCommandeId: produit.id,
        nouvelleQuantite: nouvelleQuantite,
      );

      try {
        await _refresh();
      } catch (_) {
        if (mounted) {
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      _snack('Erreur: $e');
    }
  }

  Widget _imageProduit(String imageUrl) {
    if (imageUrl.isEmpty) {
      return Container(
        color: Colors.grey.shade200,
        child: const Icon(Icons.image_not_supported_outlined),
      );
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey.shade200,
          child: const Icon(Icons.broken_image_outlined),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Commande ${widget.commandeId.substring(0, 8)}'),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'annuler') {
                _annulerCommande();
              } else if (value == 'supprimer') {
                _supprimerCommande();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'annuler',
                child: Text('Annuler la commande'),
              ),
              PopupMenuItem(
                value: 'supprimer',
                child: Text('Supprimer la commande'),
              ),
            ],
          ),
        ],
      ),
      body: FutureBuilder<Commande>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Erreur lors du chargement'),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _refresh,
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            );
          }

          final commande = snapshot.data!;
          final bool isAnnulee = commande.statut.toLowerCase() == 'annulée';

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Client: ${commande.client.getNomComplet()}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        Text('Date: ${_formatDate(commande.date)}'),
                        const SizedBox(height: 6),
                        Text('Statut: ${commande.statut}'),
                        const SizedBox(height: 6),
                        Text(
                          'Total: ${commande.total.toStringAsFixed(0)} FCFA',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Produits (${commande.produits.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...commande.produits.map((p) {
                  final lineTotal = p.price * p.quantite;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              width: 72,
                              height: 72,
                              child: _imageProduit(p.imageUrl),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  p.categorie,
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${p.price.toStringAsFixed(0)} FCFA • Total: ${lineTotal.toStringAsFixed(0)} FCFA',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (p.description.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    p.description,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: isAnnulee
                                          ? null
                                          : () => _changerQuantite(
                                              p,
                                              p.quantite - 1,
                                            ),
                                      icon: const Icon(
                                        Icons.remove_circle_outline,
                                      ),
                                    ),
                                    Text(
                                      p.quantite.toString(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: isAnnulee
                                          ? null
                                          : () => _changerQuantite(
                                              p,
                                              p.quantite + 1,
                                            ),
                                      icon: const Icon(
                                        Icons.add_circle_outline,
                                      ),
                                    ),
                                    const Spacer(),
                                    TextButton.icon(
                                      onPressed: isAnnulee
                                          ? null
                                          : () => _retirerProduit(p),
                                      icon: const Icon(Icons.delete_outline),
                                      label: const Text('Retirer'),
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
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}
