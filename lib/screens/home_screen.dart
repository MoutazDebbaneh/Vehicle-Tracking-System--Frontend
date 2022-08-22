import 'package:flutter/material.dart';
import 'package:vtracker/Services/secure_storage.dart';
import 'package:vtracker/models/user.dart';
import 'package:vtracker/screens/add_private_ride_screen.dart';
import 'package:vtracker/screens/login_screen.dart';
import 'package:vtracker/screens/ride_add_screen.dart';
import 'package:vtracker/widgets/rides_list.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = "/home";
  final navListPaths = const ['public', 'ownPrivate', 'own'];
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool isLoading = false;

  final SecureStorage secureStorage = SecureStorage();

  void _handleSignout() async {
    try {
      setState(() {
        isLoading = true;
      });
      bool? res = await User.signout();
      if (res != null && res == true) {
        User.ownUser = null;
        await secureStorage.deleteSecureData('email');
        await secureStorage.deleteSecureData('password');
        Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red[300],
        content: Row(
          children: [
            const Icon(Icons.error),
            const SizedBox(
              width: 6,
            ),
            Text(e.toString().substring(11))
          ],
        ),
      ));
    }
  }

  void _handleFloatingButtonPress() {
    Navigator.of(context).pushNamed(_currentIndex == 2
        ? RideAddScreen.routeName
        : AddPrivateRideScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("vTracker"),
        actions: [
          IconButton(
            onPressed: _handleSignout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      floatingActionButton: _currentIndex != 0 && !isLoading
          ? SizedBox(
              width: 50,
              height: 50,
              child: FloatingActionButton(
                elevation: 6,
                tooltip: 'Add ${_currentIndex == 2 ? '' : 'Private '}Ride',
                onPressed: _handleFloatingButtonPress,
                child: const Icon(Icons.add),
              ),
            )
          : Container(),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : RidesList(widget.navListPaths[_currentIndex],
                _currentIndex == 2 ? true : false),
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
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'My Rides',
          ),
        ],
      ),
    );
  }
}
