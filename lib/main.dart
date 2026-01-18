import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/items_viewmodel.dart';
import 'viewmodels/spells_viewmodel.dart';
import 'views/items_list_screen.dart';
import 'views/spells/spells_list_screen.dart';
import 'views/information/information_screen.dart';
import 'viewmodels/feats_viewmodel.dart';
import 'viewmodels/class_viewmodel.dart';

Future<void> main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ItemsViewModel()),
        ChangeNotifierProvider(create: (_) => SpellsViewModel()),
        ChangeNotifierProvider(create: (_) => FeatsViewModel()),
        ChangeNotifierProvider(create: (_) => ClassesViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'D&D Items Catalog',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 2),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    InformationScreen(),
    SpellsListScreen(),
    ItemsListScreen(),
  ];

  static const List<NavigationDestination> _destinations = [
    NavigationDestination(icon: Icon(Icons.menu_book), label: 'Information'),
    NavigationDestination(
      icon: Icon(Icons.auto_awesome_motion),
      label: 'Spells',
    ),
    NavigationDestination(icon: Icon(Icons.inventory), label: 'Items'),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: _destinations,
      ),
    );
  }
}
