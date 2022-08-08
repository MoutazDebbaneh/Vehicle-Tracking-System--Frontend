import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = "/home";
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("vTracker"),
      ),
      body: Center(
        child: Text(_currentIndex == 0 ? "Public Rides" : "Private Rides"),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (newIndex) {
          setState(() {
            _currentIndex = newIndex;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.public),
            label: 'Public Rides',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_travel),
            label: 'Private Rides',
          ),
        ],
      ),
    );
  }
}
