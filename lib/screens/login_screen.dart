import 'package:flutter/material.dart';
import 'package:vtracker/screens/home_screen.dart';

import 'package:vtracker/screens/signup_screen.dart';
import 'package:vtracker/models/user.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  static const routeName = "/login";

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  bool isLoading = false;

  void _loginHandler() {
    final isValidForm = formKey.currentState!.validate();
    if (!isValidForm) return;
    setState(() {
      isLoading = true;
    });
    User.login(emailController.text, passwordController.text).then(
      (_) {
        Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
      },
      onError: (e) {
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

        setState(() {
          isLoading = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return (Scaffold(
      backgroundColor: const Color(0xFFFBFAFF),
      body: SafeArea(
        child: Center(
          child: isLoading
              ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Color.fromARGB(255, 12, 175, 96),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 40),
                        width: 180,
                        child: Image.asset(
                          'assets/images/icon.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                      const Text(
                        "Login to your account",
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(40),
                        child: Form(
                          key: formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.email),
                                  border: UnderlineInputBorder(),
                                  labelText: 'Email Address',
                                ),
                                keyboardType: TextInputType.emailAddress,
                                controller: emailController,
                                validator: (email) {
                                  bool isValid = email != null &&
                                      RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                          .hasMatch(email);
                                  return isValid
                                      ? null
                                      : "Please enter a valid email";
                                },
                              ),
                              TextFormField(
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.lock),
                                  border: UnderlineInputBorder(),
                                  labelText: 'Password',
                                ),
                                obscureText: true,
                                controller: passwordController,
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              SizedBox(
                                width: double.infinity,
                                height: 40,
                                child: ElevatedButton(
                                  onPressed: isLoading ? null : _loginHandler,
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      const Color.fromARGB(255, 12, 175, 96),
                                    ),
                                    shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                    ),
                                  ),
                                  child: const Text(
                                    "Login",
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text("Don't have an account yet?"),
                                  TextButton(
                                    onPressed: () => Navigator.of(context)
                                        .pushReplacementNamed(
                                            SignupScreen.routeName),
                                    child: const Text("Signup"),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    ));
  }
}
