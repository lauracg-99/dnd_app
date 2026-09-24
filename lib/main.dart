import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:dnd_app/l10n/app_localizations.dart';
import 'viewmodels/items_viewmodel.dart';
import 'viewmodels/spells_viewmodel.dart';
import 'viewmodels/characters_viewmodel.dart';
import 'views/spells/spells_list_screen.dart';
import 'views/characters/characters_list_screen.dart';
import 'views/diaries/diaries_overview_screen.dart';
import 'views/information/information_screen.dart';
import 'viewmodels/feats_viewmodel.dart';
import 'viewmodels/class_viewmodel.dart';
import 'viewmodels/races_viewmodel.dart';
import 'viewmodels/backgrounds_viewmodel.dart';
import 'viewmodels/weapons_viewmodel.dart';
import 'services/character_service.dart';
import 'services/diary_service.dart';
import 'services/diary_group_service.dart';
import 'services/firebase_auth_service.dart';
import 'services/cloud_sync_service.dart';
import 'services/remote_config_service.dart';
import 'services/locale_service.dart';
import 'firebase_options.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

Future<void> main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize storage systems
  await CharacterService.initializeStorage();
  await DiaryService.initializeStorage();
  await DiaryGroupService.initializeStorage();

  // Initialize Firebase services
  final authService = FirebaseAuthService();
  final syncService = CloudSyncService();
  // Initialize Remote Config so feature flags are available early
  await RemoteConfigService.instance.initialize();
  // Initialize auth and wait for Firebase Auth to restore the current session
  await authService.initialize();
  await syncService.initialize();

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
        ChangeNotifierProvider(create: (_) => WeaponsViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = AppLocaleStorage.defaultLocale;

  @override
  void initState() {
    super.initState();
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final savedLocale = await AppLocaleStorage.loadLocale();

    if (!mounted) {
      return;
    }

    setState(() {
      _locale = savedLocale;
    });
  }

  Future<void> _setLocale(Locale locale) async {
    if (!AppLocalizations.supportedLocales.contains(locale)) {
      return;
    }

    await AppLocaleStorage.saveLocale(locale);

    if (!mounted) {
      return;
    }

    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
      title: 'D&D',
      locale: _locale,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: ZoomPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 2),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),
      ),
      builder: (context, child) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: child,
        );
      },
      home: MainNavigationScreen(onLocaleChanged: _setLocale, locale: _locale),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({
    super.key,
    required this.onLocaleChanged,
    required this.locale,
  });

  final ValueChanged<Locale> onLocaleChanged;
  final Locale locale;

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  List<Widget> get _screens {
    return [
      CharactersListScreen(
        locale: widget.locale,
        onLocaleChanged: widget.onLocaleChanged,
      ),
      const DiariesOverviewScreen(),
      const SpellsListScreen(),
      const InformationScreen(),
    ];
  }

  List<NavigationDestination> get _destinations {
    final l10n = AppLocalizations.of(context)!;

    return [
      NavigationDestination(
        icon: const Icon(Icons.person),
        label: l10n.navCharacters,
      ),
      NavigationDestination(
        icon: const Icon(Icons.book),
        label: l10n.navDiaries,
      ),
      NavigationDestination(
        icon: const Icon(Symbols.playing_cards),
        label: l10n.navSpells,
      ),
      NavigationDestination(
        icon: const Icon(Icons.menu_book),
        label: l10n.navInformation,
      ),
    ];
  }

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
