import 'package:app_e_commerce/commande_screen.dart';
import 'package:app_e_commerce/marketplace_screen.dart';
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

  final screens = [
    const MarketplaceScreen(),
    const PanierScreen(),
    const CommandeScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Icônes avec couleur dynamique selon la page sélectionnée
    final items = [
      Icon(Icons.store,
          size: 30, color: _pageIndex == 0 ? Colors.white : Colors.black),
      Icon(Icons.shopping_cart,
          size: 30, color: _pageIndex == 1 ? Colors.white : Colors.black),
      Icon(Icons.list_alt,
          size: 30, color: _pageIndex == 2 ? Colors.white : Colors.black),
      Icon(Icons.person,
          size: 30, color: _pageIndex == 3 ? Colors.white : Colors.black),
    ];

    return Scaffold(
      body: screens[_pageIndex],
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.white,                 // couleur derrière la barre
        color: const Color(0xFFF27438),               // couleur de la barre
        buttonBackgroundColor: const Color.fromARGB(168, 234, 92, 26), // icône sélectionnée
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
