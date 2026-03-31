// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/storage_service.dart';
import 'screens/tasbeeh_screen.dart';
import 'screens/hadith_screen.dart';
import 'screens/verses_screen.dart';
import 'screens/adhkar_screen.dart';
import 'widgets/widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة التخزين
  final storage = StorageService();
  await storage.init();

  // تعيين الاتجاه RTL
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const RawdatAlDhakirinApp());
}

class RawdatAlDhakirinApp extends StatefulWidget {
  const RawdatAlDhakirinApp({Key? key}) : super(key: key);

  @override
  State<RawdatAlDhakirinApp> createState() => _RawdatAlDhakirinAppState();
}

class _RawdatAlDhakirinAppState extends State<RawdatAlDhakirinApp> {
  bool _isDarkMode = false;
  int _currentIndex = 0;
  final StorageService _storage = StorageService();

  final List<Widget> _screens = [
    const TasbeehScreen(),
    const HadithScreen(),
    const VersesScreen(),
    const AdhkarScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    await _storage.init();
    setState(() {
      _isDarkMode = _storage.getDarkMode();
    });
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
    _storage.setDarkMode(_isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'روضة الذاكرين',
      debugShowCheckedModeBanner: false,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            centerTitle: true,
            title: Column(
              children: [
                Text(
                  'روضة الذاكرين',
                  style: GoogleFonts.amiri(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Rawdat Al-Dhakirin',
                  style: GoogleFonts.amiri(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
                onPressed: _toggleTheme,
                tooltip: _isDarkMode ? 'الوضع الفاتح' : 'الوضع المظلم',
              ),
            ],
          ),
          body: IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          bottomNavigationBar: BottomNavBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
          ),
        ),
      ),
    );
  }

  ThemeData _buildLightTheme() {
    final base = ThemeData.light();
    return base.copyWith(
      colorScheme: ColorScheme.light(
        primary: const Color(0xFF5D7B6F), // زيتوني
        secondary: const Color(0xFFD4A373), // ذهبي
        tertiary: const Color(0xFF8B9D83),
        background: const Color(0xFFF5F5F0),
        surface: Colors.white,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: const Color(0xFF2C3E50),
        onSurface: const Color(0xFF2C3E50),
      ),
      scaffoldBackgroundColor: const Color(0xFFF5F5F0),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF5D7B6F),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.amiri(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    final base = ThemeData.dark();
    return base.copyWith(
      colorScheme: ColorScheme.dark(
        primary: const Color(0xFF7A9E8E), // زيتوني فاتح
        secondary: const Color(0xFFE6C9A8), // ذهبي فاتح
        tertiary: const Color(0xFF9CAF94),
        background: const Color(0xFF1A1A1A),
        surface: const Color(0xFF2D2D2D),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: const Color(0xFFE0E0E0),
        onSurface: const Color(0xFFE0E0E0),
      ),
      scaffoldBackgroundColor: const Color(0xFF1A1A1A),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF2D2D2D),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.amiri(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        color: const Color(0xFF2D2D2D),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
