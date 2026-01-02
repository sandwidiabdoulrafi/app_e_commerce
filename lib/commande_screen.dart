import 'package:flutter/material.dart';
import 'package:app_e_commerce/models/Commande.dart';
import 'package:app_e_commerce/models/user.dart';
import 'package:app_e_commerce/services/commade_service.dart';
import 'package:app_e_commerce/services/user_service.dart';
import 'package:app_e_commerce/commande_detail_screen.dart';

class CommandeScreen extends StatefulWidget {
  const CommandeScreen({super.key});

  @override
  State<CommandeScreen> createState() => _CommandeScreenState();
}

class _CommandeScreenState extends State<CommandeScreen> {
  final CommandeService _commandeService = CommandeService();
  final UserService _userService = UserService();

  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';
  DateTime? _selectedDate;

  late Future<List<Commande>> _future;

  @override
  void initState() {
    super.initState();
    _future = _chargerCommandes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Charger les commandes
  Future<List<Commande>> _chargerCommandes() async {
    final User? client = await _userService.getUtilisateurParId('12345');
    if (client == null) {
      throw Exception('Utilisateur non trouvé');
    }

    return _commandeService.getCommandesPourClient(client: client);
  }

  // Raafraichissement de l'ecran apres actualisation de la bdd
  Future<void> _refresh() async {
    setState(() {
      _future = _chargerCommandes();
    });
    await _future;
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

  Widget _leadingImage(Commande commande) {
    final imageUrl = commande.produits.isNotEmpty
        ? commande.produits.first.imageUrl
        : '';

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 54,
        height: 54,
        child: imageUrl.isEmpty
            ? Container(
                color: Colors.grey.shade200,
                child: const Icon(Icons.image_not_supported_outlined),
              )
            : Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.broken_image_outlined),
                  );
                },
              ),
      ),
    );
  }

  Future<void> _ouvrirDetails(Commande commande) async {
    final res = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => CommandeDetailScreen(commandeId: commande.id),
      ),
    );

    if (res == true) {
      await _refresh();
    }
  }

  Future<void> _annuler(Commande commande) async {
    final ok = await _confirmer(
      titre: 'Annuler la commande',
      message: 'Voulez-vous annuler cette commande ?',
    );
    if (!ok) return;

    try {
      await _commandeService.annulerCommande(commandeId: commande.id);
      await _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
  }

  Future<void> _supprimer(Commande commande) async {
    final ok = await _confirmer(
      titre: 'Supprimer la commande',
      message: 'Supprimer définitivement cette commande ?',
    );
    if (!ok) return;

    try {
      await _commandeService.supprimerCommande(commandeId: commande.id);
      await _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
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

  String _formatDateOnly(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = _selectedDate ?? now;
    final res = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 5),
    );
    if (res == null) return;
    setState(() {
      _selectedDate = res;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Commandes')),
      body: FutureBuilder<List<Commande>>(
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
                    const Text('Erreur lors du chargement des commandes'),
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

          final commandes = snapshot.data ?? <Commande>[];

          final filtered = commandes.where((c) {
            final term = _searchTerm.trim();
            final bool matchesNumero = term.isEmpty
                ? true
                : c.numero.toString().contains(term);

            final bool matchesDate = _selectedDate == null
                ? true
                : _isSameDay(
                    DateTime.fromMillisecondsSinceEpoch(c.date).toLocal(),
                    _selectedDate!,
                  );

            return matchesNumero && matchesDate;
          }).toList();

          if (commandes.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                children: const [
                  SizedBox(height: 200),
                  Center(child: Text('Aucune commande pour le moment')),
                ],
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      keyboardType: TextInputType.number,
                      onChanged: (v) {
                        setState(() {
                          _searchTerm = v;
                        });
                      },
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        labelText: 'Rechercher par numéro',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pickDate,
                            icon: const Icon(Icons.calendar_month_outlined),
                            label: Text(
                              _selectedDate == null
                                  ? 'Filtrer par date'
                                  : _formatDateOnly(_selectedDate!),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (_selectedDate != null)
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _selectedDate = null;
                              });
                            },
                            icon: const Icon(Icons.close),
                            tooltip: 'Effacer le filtre date',
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refresh,
                  child: filtered.isEmpty
                      ? ListView(
                          children: const [
                            SizedBox(height: 200),
                            Center(child: Text('Aucune commande trouvée')),
                          ],
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final commande = filtered[index];
                            return Card(
                              child: ListTile(
                                onTap: () => _ouvrirDetails(commande),
                                leading: _leadingImage(commande),
                                title: Text('Commande #${commande.numero}'),
                                subtitle: Text(
                                  '${_formatDate(commande.date)}\n${commande.produits.length} article(s) • Statut: ${commande.statut}',
                                ),
                                isThreeLine: true,
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${commande.total.toStringAsFixed(0)} FCFA',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    PopupMenuButton<String>(
                                      onSelected: (value) {
                                        if (value == 'details') {
                                          _ouvrirDetails(commande);
                                        } else if (value == 'annuler') {
                                          _annuler(commande);
                                        } else if (value == 'supprimer') {
                                          _supprimer(commande);
                                        }
                                      },
                                      itemBuilder: (context) => const [
                                        PopupMenuItem(
                                          value: 'details',
                                          child: Text('Détails'),
                                        ),
                                        PopupMenuItem(
                                          value: 'annuler',
                                          child: Text('Annuler'),
                                        ),
                                        PopupMenuItem(
                                          value: 'supprimer',
                                          child: Text('Supprimer'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
