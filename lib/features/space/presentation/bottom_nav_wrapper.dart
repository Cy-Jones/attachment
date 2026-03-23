import 'package:flutter/material.dart';
import 'home_screen.dart'; // Make sure this matches your local path

class BottomNavWrapper extends StatefulWidget {
  const BottomNavWrapper({Key? key}) : super(key: key);

  @override
  State<BottomNavWrapper> createState() => _BottomNavWrapperState();
}

class _BottomNavWrapperState extends State<BottomNavWrapper> {
  int _selectedIndex = 0;

  // Index 0 routes to the stable home screen we just recovered.
  // The rest are routed to a private dummy widget to prevent null pointer exceptions.
  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    _DummyScreen(title: 'Tab 2 (Explore)', icon: Icons.explore),
    _DummyScreen(title: 'Tab 3 (Profile)', icon: Icons.person),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // We don't need an AppBar here because each individual screen (like HomeScreen)
      // should manage its own AppBar. This prevents nested Scaffolds from fighting over the safe area.
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Prevents shifting layout bugs
      ),
    );
  }
}

// A rock-solid, isolated dummy widget for the inactive tabs.
// No external packages, no complex rendering. Just pixels on a screen.
class _DummyScreen extends StatelessWidget {
  final String title;
  final IconData icon;

  const _DummyScreen({
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.blueGrey,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              '$title Placeholder',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Awaiting stable module injection.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}