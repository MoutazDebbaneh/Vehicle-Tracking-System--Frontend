import 'package:flutter/material.dart';
import 'package:vtracker/services/auth_controller.dart';
import 'package:vtracker/services/secure_storage.dart';
import 'package:vtracker/models/instance.dart';
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
    bool signedOut = await AuthController.signout(context);
    if (signedOut) {
      _returnToLoginScreen();
    }
    setState(() {
      isLoading = false;
    });
  }

  _returnToLoginScreen() {
    Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
  }

  void _handleFloatingButtonPress() {
    Navigator.of(context).pushNamed(_currentIndex == 2
        ? RideAddScreen.routeName
        : AddPrivateRideScreen.routeName);
  }

  void _getCurrentInstance() async {
    while (User.currentInstance == null) {
      try {
        User.currentInstance =
            await RideInstance.get(User.ownUser!.currentDrivingInstance!);
      } catch (e) {
        print(e.toString());
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    if (User.ownUser!.currentDrivingInstance != null &&
        User.ownUser!.currentDrivingInstance!.isNotEmpty) {
      if (User.currentInstance == null) {
        setState(() {
          isLoading = true;
        });
        _getCurrentInstance();
      }
    }
    super.initState();
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
