import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;

import 'package:finance_manager/services/storage_service.dart';
import 'package:finance_manager/models/transaction.dart';
import 'package:finance_manager/models/category.dart';

import 'package:finance_manager/screens/home_screen.dart';
import 'package:finance_manager/screens/transactions_screen.dart';
import 'package:finance_manager/screens/add_transaction_screen.dart';
import 'package:finance_manager/screens/analytics_screen.dart';
import 'package:finance_manager/screens/settings_screen.dart';
import 'package:finance_manager/screens/welcome_screen.dart';

// Removed GoogleFonts import
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initCategories();

  runApp(
    provider.ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const MyApp(),
    ),
  );
}

Future<void> _initCategories() async {
  final storageService = StorageService();
  var categories = await storageService.getCategories();

  if (categories.isEmpty) {
    const categories = [
      Category(id: '1', name: 'Salary'),
      Category(id: '2', name: 'Freelance'),
      Category(id: '3', name: 'Investment'),
      Category(id: '4', name: 'Food'),
      Category(id: '5', name: 'Transport'),
      Category(id: '6', name: 'Shopping'),
      Category(id: '7', name: 'Entertainment'),
      Category(id: '8', name: 'Bills'),
      Category(id: '9', name: 'Healthcare'),
    ];
    await storageService.saveCategories(categories);
  }
}

class AppState extends ChangeNotifier {
  int _selectedIndex = 0;
  List<Transaction> _transactions = [];
  List<Category> _categories = [];

  final StorageService _storageService = StorageService();

  AppState();

  Future<void> initializeData() async => _loadData();

  int get selectedIndex => _selectedIndex;
  List<Transaction> get transactions => _transactions;
  List<Category> get categories => _categories;

  void updateSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  Future<void> _loadData() async {
    _transactions = await _storageService.getTransactions();
    _categories = await _storageService.getCategories();
    notifyListeners();
  }

  Future<void> addTransaction(Transaction transaction) async {
    _transactions.add(transaction);
    await _storageService.saveTransactions(_transactions);
    notifyListeners();
  }

  Future<void> deleteTransaction(String id) async {
    _transactions.removeWhere((t) => t.id == id);
    await _storageService.saveTransactions(_transactions);
    notifyListeners();
  }

  Future<void> addCategory(Category category) async {
    _categories.add(category);
    await _storageService.saveCategories(_categories);
    notifyListeners();
  }

  Future<void> deleteCategory(String id) async {
    _categories.removeWhere((c) => c.id == id);
    await _storageService.saveCategories(_categories);
    notifyListeners();
  }

  Future<void> clearAllData() async {
    await _storageService.clearAllData();
    _transactions = [];
    _categories = await _storageService.getCategories(); // reload default
    notifyListeners();
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<bool> _hasLaunchedBefore;

  @override
  void initState() {
    super.initState();
    _hasLaunchedBefore = _checkFirstLaunch();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider.Provider.of<AppState>(context, listen: false).initializeData();
    });
  }

  Future<bool> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('has_launched_before') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance Manager',
      theme: _buildTheme(context),
      home: FutureBuilder<bool>(
        future: _hasLaunchedBefore,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return (snapshot.data ?? false)
                ? const MainScreen()
                : const WelcomeScreen();
          }
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }

  ThemeData _buildTheme(BuildContext context) {
    const primaryAccent = Color(0xFF00D4FF);
    const negativeAccent = Color(0xFFFF6B6B);
    const deepBackground = Color(0xFF0A0E21);
    const surfaceGradientStart = Color(0xFF1A1F3A);
    const surfaceGradientEnd = Color(0xFF151929);

    final base = ThemeData.dark();

    return base.copyWith(
      // useMaterial3: true,
      scaffoldBackgroundColor: deepBackground,
      primaryColor: primaryAccent,
      colorScheme: const ColorScheme.dark(
        primary: primaryAccent,
        secondary: primaryAccent,
        error: negativeAccent,
        // background: deepBackground,
        surface: surfaceGradientStart,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: Colors.white,
        // onBackground: Colors.white,
        onError: Colors.white,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.bold, letterSpacing: -0.25),
        displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.normal, letterSpacing: 0.0),
        displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.normal, letterSpacing: 0.0),
        headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 0.0),
        headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 0.0),
        headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 0.0),
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 0.0),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 0.15),
        titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1),
        bodyLarge: TextStyle(fontSize: 16, letterSpacing: 0.5),
        bodyMedium: TextStyle(fontSize: 14, letterSpacing: 0.25),
        bodySmall: TextStyle(fontSize: 12, letterSpacing: 0.4),
        labelLarge: TextStyle(fontSize: 14, letterSpacing: 1.0),
        labelMedium: TextStyle(fontSize: 12, letterSpacing: 1.0),
        labelSmall: TextStyle(fontSize: 11, letterSpacing: 1.5),
      ).apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        toolbarTextStyle: TextStyle(fontSize: 16, letterSpacing: 0.3),
        titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 0.5, color: Colors.white),
      ),

      cardTheme: CardThemeData(
        color: surfaceGradientStart,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(vertical: 8),
      ),

      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: surfaceGradientEnd.withValues(alpha: 0.6),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        hintStyle: const TextStyle(color: Colors.white70, letterSpacing: 0.3),
        labelStyle: const TextStyle(color: Colors.white, letterSpacing: 0.3),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryAccent,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryAccent,
          textStyle: const TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.3),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: surfaceGradientEnd,
        selectedColor: primaryAccent.withValues(alpha: 0.12),
        labelStyle: const TextStyle(color: Colors.white, letterSpacing: 0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceGradientEnd,
        selectedItemColor: primaryAccent,
        unselectedItemColor: Colors.grey[500],
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, letterSpacing: 0.3),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12, letterSpacing: 0.2),
      ),

      // dialogBackgroundColor: surfaceGradientStart,
      splashColor: primaryAccent.withValues(alpha: 0.12),
      hoverColor: primaryAccent.withValues(alpha: 0.06),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _pages = const [
    HomeScreen(),
    TransactionsScreen(),
    AddTransactionScreen(),
    AnalyticsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: provider.Consumer<AppState>(
        builder: (context, appState, _) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: _pages[appState.selectedIndex],
          );
        },
      ),
      bottomNavigationBar: provider.Consumer<AppState>(
        builder: (context, appState, _) {
          return BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: appState.selectedIndex,
            onTap: appState.updateSelectedIndex,
            selectedItemColor: const Color(0xFF00D4FF),
            unselectedItemColor: Colors.grey[500],
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              letterSpacing: 0.3,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 12,
              letterSpacing: 0.2,
            ),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                icon: Icon(Icons.list_alt),
                label: 'Transactions',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add_circle),
                label: 'Add',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.analytics),
                label: 'Analytics',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          );
        },
      ),
    );
  }
}