import 'package:flutter/material.dart';
import 'package:vtracker/screens/home_screen.dart';
import 'package:vtracker/screens/login_screen.dart';
import 'package:vtracker/screens/signup_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VTracker',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        fontFamily: 'Lato',
      ),
      home: const MyHomePage(),
      debugShowCheckedModeBanner: false,
      routes: {
        LoginScreen.routeName: (ctx) => const LoginScreen(),
        SignupScreen.routeName: (ctx) => const SignupScreen(),
        HomeScreen.routeName: (ctx) => const HomeScreen(),
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const LoginScreen();
  }
}
