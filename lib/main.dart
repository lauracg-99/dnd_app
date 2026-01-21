import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/items_viewmodel.dart';
import 'viewmodels/spells_viewmodel.dart';
import 'viewmodels/characters_viewmodel.dart';
import 'views/spells/spells_list_screen.dart';
import 'views/characters/characters_list_screen.dart';
import 'views/characters/diaries_overview_screen.dart';
import 'views/information/information_screen.dart';
import 'viewmodels/feats_viewmodel.dart';
import 'viewmodels/class_viewmodel.dart';
import 'viewmodels/races_viewmodel.dart';
import 'viewmodels/backgrounds_viewmodel.dart';
import 'services/character_service.dart';
import 'services/diary_service.dart';

Future<void> main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage systems
  await CharacterService.initializeStorage();
  await DiaryService.initializeStorage();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ItemsViewModel()),
        ChangeNotifierProvider(create: (_) => SpellsViewModel()),
        ChangeNotifierProvider(create: (_) => CharactersViewModel()),
        ChangeNotifierProvider(create: (_) => FeatsViewModel()),
        ChangeNotifierProvider(create: (_) => ClassesViewModel()),
        ChangeNotifierProvider(create: (_) => RacesViewModel()),
        ChangeNotifierProvider(create: (_) => BackgroundsViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);

          if (!currentFocus.hasPrimaryFocus &&
              currentFocus.focusedChild != null) {
            FocusManager.instance.primaryFocus?.unfocus();
          }
        },
      child: MaterialApp(
        title: 'D&D',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(centerTitle: true, elevation: 2),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
        ),
        home: const MainNavigationScreen(),
      ),
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
    CharactersListScreen(),
    DiariesOverviewScreen(),
    SpellsListScreen(),
    InformationScreen(),
   // ItemsListScreen(),
  ];

  static const List<NavigationDestination> _destinations = [
    NavigationDestination(icon: Icon(Icons.person), label: 'Characters'),    
    NavigationDestination(icon: Icon(Icons.book), label: 'Diaries'),
    NavigationDestination(
      icon: Icon(Icons.auto_awesome_motion),
      label: 'Spells',
    ),  
    NavigationDestination(icon: Icon(Icons.menu_book), label: 'Information'),  
    //NavigationDestination(icon: Icon(Icons.inventory), label: 'Items'),
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
