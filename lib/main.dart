import 'package:app_e_commerce/commande_screen.dart';
import 'package:app_e_commerce/database/app_database.dart';
import 'package:app_e_commerce/database/user_dao.dart';
import 'package:app_e_commerce/marketplace_screen.dart';
import 'package:app_e_commerce/models/User.dart';
import 'package:app_e_commerce/panier_screen.dart';
import 'package:app_e_commerce/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:app_e_commerce/themes/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Marketplace App',
      theme: appTheme,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _pageIndex = 0;
  late UserDao userDao;
  User? user;
  bool _loading = true; // ← AJOUTÉ

  @override
  void initState() {
    super.initState();
    initUser();
  }

  Future<void> initUser() async {
    userDao = UserDao();
    User tempUser = User(
      id: '12345',
      nom: 'Sandwidi',
      prenom: 'Abdoul Rafi',
      email: 'rafi@un_virt_bf.com',
      telephone: '+226 010212345',
      motDePasse: 'password123',
      imgProfile:
          'https://lefaso.net/local/cache-vignettes/L680xH384/arton115709-00e9c.jpg?1762806111',
    );
    User result = await userDao.insertIfNotExistElseReturnUser(tempUser);
    setState(() {
      user = result;
      _loading = false; // ← AJOUTÉ
    });
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Attendre que l'utilisateur soit chargé
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final List<Widget> screens = [
      const MarketplaceScreen(),
      const PanierScreen(),
      const CommandeScreen(),
      ProfileScreen(user: user!), // ✅ Maintenant user n'est plus null
    ];

    // Icônes avec couleur dynamique selon la page sélectionnée
    final items = [
      Icon(
        Icons.store,
        size: 30,
        color: _pageIndex == 0 ? Colors.white : Colors.black,
      ),
      Icon(
        Icons.shopping_cart,
        size: 30,
        color: _pageIndex == 1 ? Colors.white : Colors.black,
      ),
      Icon(
        Icons.list_alt,
        size: 30,
        color: _pageIndex == 2 ? Colors.white : Colors.black,
      ),
      Icon(
        Icons.person,
        size: 30,
        color: _pageIndex == 3 ? Colors.white : Colors.black,
      ),
    ];

    return Scaffold(
      body: screens[_pageIndex],
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.white,
        color: const Color(0xFFF27438),
        buttonBackgroundColor: const Color.fromARGB(168, 234, 92, 26),
        height: 60,
        items: items,
        index: _pageIndex,
        animationDuration: const Duration(milliseconds: 300),
        animationCurve: Curves.easeInOut,
        onTap: (index) {
          setState(() {
            _pageIndex = index;
          });
        },
      ),
    );
  }
}