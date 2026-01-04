import 'package:flutter/material.dart';
import 'package:app_e_commerce/models/Panier.dart';
import 'package:app_e_commerce/models/user.dart';
import 'package:app_e_commerce/services/commade_service.dart';
import 'package:app_e_commerce/services/panier_service.dart';

class PaymentScreen extends StatefulWidget {
  final Panier panier;
  final User client;

  const PaymentScreen({
    super.key,
    required this.panier,
    required this.client,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final CommandeService _commandeService = CommandeService();
  final PanierService _panierService = PanierService();
  
  String _methodePaiement = 'mobile_money';
  String? _operateurMobileMoney; // Orange, Moov, Wave, etc.
  bool _isProcessing = false;
  
  final TextEditingController _numeroTelController = TextEditingController();

  @override
  void dispose() {
    _numeroTelController.dispose();
    super.dispose();
  }

  Future<void> _traiterPaiement() async {
    // Validation simple selon la méthode
    if (_methodePaiement == 'mobile_money') {
      if (_operateurMobileMoney == null) {
        _afficherMessage('Veuillez choisir un opérateur');
        return;
      }
      if (_numeroTelController.text.isEmpty) {
        _afficherMessage('Veuillez entrer votre numéro');
        return;
      }
    }

    setState(() => _isProcessing = true);

    try {
      // Simulation du traitement de paiement (2 secondes)
      await Future.delayed(const Duration(seconds: 2));

      // Créer la commande
      final commande = await _commandeService.creerCommandeDepuisPanier(
        client: widget.client,
        panier: widget.panier,
      );

      // Vider le panier
      await _panierService.viderPanier();

      if (mounted) {
        _afficherSucces(commande.numero);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        _afficherMessage('Erreur lors du paiement : $e');
      }
    }
  }

  void _afficherSucces(int numeroCommande) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 80,
            ),
            const SizedBox(height: 16),
            const Text(
              'Paiement réussi !',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Commande N° $numeroCommande',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Votre commande a été créée avec succès',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Fermer le dialog
              Navigator.of(context).pop(true); // Retourner au panier
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _afficherMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paiement'),
        centerTitle: true,
      ),
      body: _isProcessing
          ? _buildProcessingView()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRecapitulatif(theme),
                  const SizedBox(height: 24),
                  _buildMethodesPaiement(theme),
                  const SizedBox(height: 24),
                  _buildFormulaireMethode(),
                  const SizedBox(height: 32),
                  _buildBoutonPayer(theme),
                ],
              ),
            ),
    );
  }

  Widget _buildProcessingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            'Traitement du paiement...',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecapitulatif(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Récapitulatif',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Articles (${widget.panier.totalQuantite})',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                Text(
                  '${widget.panier.total.toStringAsFixed(0)} FCFA',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total à payer',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${widget.panier.total.toStringAsFixed(0)} FCFA',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodesPaiement(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Méthode de paiement',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildMethodeOption(
          value: 'mobile_money',
          icon: Icons.phone_android,
          title: 'Mobile Money',
          subtitle: 'Orange, Moov, Wave...',
        ),
        const SizedBox(height: 8),
        _buildMethodeOption(
          value: 'carte',
          icon: Icons.credit_card,
          title: 'Carte bancaire',
          subtitle: 'Visa, Mastercard',
        ),
        const SizedBox(height: 8),
        _buildMethodeOption(
          value: 'especes',
          icon: Icons.money,
          title: 'Paiement à la livraison',
          subtitle: 'En espèces',
        ),
      ],
    );
  }

  Widget _buildMethodeOption({
    required String value,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _methodePaiement == value;

    return InkWell(
      onTap: () => setState(() => _methodePaiement = value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? Theme.of(context).primaryColor.withOpacity(0.05)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).primaryColor,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormulaireMethode() {
    switch (_methodePaiement) {
      case 'mobile_money':
        return _buildFormulaireMobileMoney();
      case 'carte':
        return _buildMessageCarte();
      case 'especes':
        return _buildMessageEspeces();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildFormulaireMobileMoney() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choisissez votre opérateur',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildOperateurChip('Orange Money', Colors.orange),
            _buildOperateurChip('Moov Money', Colors.blue),
            _buildOperateurChip('Wave', Colors.purple),
            _buildOperateurChip('Coris Money', Colors.green),
          ],
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _numeroTelController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: 'Numéro de téléphone',
            hintText: 'Ex: 70123456 ou 50123456',
            prefixIcon: const Icon(Icons.phone),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[700]),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Vous recevrez une notification sur votre téléphone pour valider le paiement',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue[900],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOperateurChip(String nom, Color couleur) {
    final isSelected = _operateurMobileMoney == nom;
    
    return FilterChip(
      label: Text(nom),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _operateurMobileMoney = selected ? nom : null;
        });
      },
      selectedColor: couleur.withOpacity(0.2),
      checkmarkColor: couleur,
      labelStyle: TextStyle(
        color: isSelected ? couleur : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? couleur : Colors.grey[300]!,
        width: isSelected ? 2 : 1,
      ),
    );
  }

  Widget _buildMessageCarte() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue[700], size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Vous serez redirigé vers une page sécurisée pour entrer les informations de votre carte',
              style: TextStyle(
                fontSize: 14,
                color: Colors.blue[900],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageEspeces() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.orange[700], size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Vous paierez en espèces lors de la livraison de votre commande',
              style: TextStyle(
                fontSize: 14,
                color: Colors.orange[900],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoutonPayer(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _traiterPaiement,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: Text(
          'Confirmer le paiement - ${widget.panier.total.toStringAsFixed(0)} FCFA',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}