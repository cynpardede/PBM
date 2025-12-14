import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/create_book_screen.dart'; 
// Pastikan dua import di atas sudah ada

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SeeBook',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // 1. Dark Mode
        brightness: Brightness.dark,
        // 2. Skema Merah & Orange (Primary/Accent)
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red.shade700,
          brightness: Brightness.dark,
          primary: Colors.red.shade700,
          secondary: Colors.deepOrange.shade700,
          surface: Colors.grey.shade900,
        ),
        // 3. Font modern
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  // Gunakan GlobalKey untuk mengakses fungsi refresh dari Home Screen
  final GlobalKey<HomeScreenState> homeScreenKey = GlobalKey<HomeScreenState>();

  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      // HomeScreen membutuhkan GlobalKey untuk refresh
      HomeScreen(key: homeScreenKey), 
      // CreateBookScreen membutuhkan callback
      CreateBookScreen(onBookCreated: _onBookCreated), 
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  
  // Callback saat buku berhasil dibuat (dipanggil dari ChapterInputScreen)
  void _onBookCreated() {
    // 1. Pindah kembali ke Home (index 0)
    setState(() {
      _selectedIndex = 0;
    });
    // 2. Trigger refresh data di Home Screen
    // Memanggil _refreshBooks() dari state HomeScreen
    homeScreenKey.currentState?.refreshBooks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SeeBook', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.surface,
        centerTitle: true,
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.add_box),
            label: 'Create Book',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary, 
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
    );
  }
}