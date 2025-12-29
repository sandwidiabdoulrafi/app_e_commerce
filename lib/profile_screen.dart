import 'package:app_e_commerce/database/user_dao.dart';
import 'package:app_e_commerce/models/user.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  final User user;

  const ProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late User _currentUser;
  late UserDao userDao;
  bool _isEditing = false;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs pour les champs d'édition
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _telephoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    _initializeControllers();
  }

  void _initializeControllers() {
    _nomController.text = _currentUser.nom;
    _prenomController.text = _currentUser.prenom;
    _emailController.text = _currentUser.email;
    _telephoneController.text = _currentUser.telephone;
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        _initializeControllers();
      }
    });
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      await userDao.updateUser(_currentUser);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Simuler une sauvegarde asynchrone
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        _currentUser = _currentUser.copyWith(
          nom: _nomController.text,
          prenom: _prenomController.text,
          email: _emailController.text,
          telephone: _telephoneController.text,
        );
        _isEditing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profil mis à jour avec succès'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _changeProfilePicture() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Prendre une photo'),
              onTap: () {
                Navigator.pop(context);
                // Implémenter la prise de photo
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choisir depuis la galerie'),
              onTap: () {
                Navigator.pop(context);
                // Implémenter la sélection depuis la galerie
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text(
                'Supprimer la photo',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                setState(() {
                  _currentUser = _currentUser.copyWith(imgProfile: '');
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return GestureDetector(
      onTap: !_isEditing ? null : _changeProfilePicture,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.blue, width: 2),
            ),
            child: ClipOval(
              child: _currentUser.imgProfile.isNotEmpty
                  ? Image.network(
                      _currentUser.imgProfile,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildDefaultAvatar(),
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
                    )
                  : _buildDefaultAvatar(),
            ),
          ),
          if (!_isEditing)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt,
                size: 18,
                color: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Icon(Icons.person, size: 60, color: Colors.grey),
      ),
    );
  }

  Widget _buildEditableField({
    required String label,
    required String hintText,
    required IconData icon,
    required TextEditingController controller,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    bool isEnabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
          child: Text(
            label,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ),
        TextFormField(
          controller: controller,
          enabled: _isEditing && isEnabled,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(icon, color: Colors.blue),
            filled: !_isEditing,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
        centerTitle: true,
        actions: [
          if (_isEditing && !_isLoading)
            IconButton(
              onPressed: _saveChanges,
              icon: const Icon(Icons.check),
              tooltip: 'Sauvegarder',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Photo de profil
                    Center(
                      child: Column(
                        children: [
                          _buildProfileImage(),
                          const SizedBox(height: 16),
                          Text(
                            _currentUser.getNomComplet(),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ID: ${_currentUser.id}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Formulaire
                    Column(
                      children: [
                        _buildEditableField(
                          label: 'Nom',
                          hintText: 'Entrez votre nom',
                          icon: Icons.person,
                          controller: _nomController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Le nom est obligatoire';
                            }
                            if (value.length < 2) {
                              return 'Le nom doit contenir au moins 2 caractères';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        _buildEditableField(
                          label: 'Prénom',
                          hintText: 'Entrez votre prénom',
                          icon: Icons.person_outline,
                          controller: _prenomController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Le prénom est obligatoire';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        _buildEditableField(
                          label: 'Email',
                          hintText: 'Entrez votre email',
                          icon: Icons.email,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'L\'email est obligatoire';
                            }
                            if (!RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            ).hasMatch(value)) {
                              return 'Email invalide';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        _buildEditableField(
                          label: 'Téléphone',
                          hintText: 'Entrez votre téléphone',
                          icon: Icons.phone,
                          controller: _telephoneController,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Le téléphone est obligatoire';
                            }
                            if (!RegExp(r'^[+0-9\s\-]{10,}$').hasMatch(value)) {
                              return 'Numéro de téléphone invalide';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Boutons d'action
                    if (_isEditing)
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _toggleEditMode,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                side: BorderSide(color: Colors.grey[300]!),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Annuler',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _saveChanges,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Sauvegarder',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      ElevatedButton(
                        onPressed: _toggleEditMode,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.edit, size: 20, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Modifier le profil',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 16),

                    // Bouton de déconnexion
                    OutlinedButton(
                      onPressed: () {
                        _showLogoutDialog();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Déconnexion',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implémenter la logique de déconnexion
              // AuthService.logout();
              // Navigator.pushReplacementNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    super.dispose();
  }
}
