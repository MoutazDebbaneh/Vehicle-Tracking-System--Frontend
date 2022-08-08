import 'package:flutter/material.dart';

import 'package:vtracker/screens/login_screen.dart';
import '../models/user.dart';
import 'home_screen.dart';

class SignupScreen extends StatefulWidget {
  static const routeName = "/signup";

  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  bool isLoading = false;

  void _signupHandler() {
    final isValidForm = formKey.currentState!.validate();
    if (!isValidForm) return;
    setState(() {
      isLoading = true;
    });
    User.signup(
      firstNameController.text,
      lastNameController.text,
      emailController.text,
      passwordController.text,
    ).then(
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
                        "Create a new account",
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
                                  border: UnderlineInputBorder(),
                                  labelText: 'First Name',
                                ),
                                // keyboardType: TextInputType.text,
                                controller: firstNameController,
                                validator: (firstName) {
                                  return firstName!.isNotEmpty
                                      ? null
                                      : "Please enter a first name";
                                },
                              ),
                              TextFormField(
                                decoration: const InputDecoration(
                                  border: UnderlineInputBorder(),
                                  labelText: 'Last Name',
                                ),
                                // keyboardType: TextInputType.text,
                                controller: lastNameController,
                                validator: (lastName) {
                                  return lastName!.isNotEmpty
                                      ? null
                                      : "Please enter a last name";
                                },
                              ),
                              TextFormField(
                                decoration: const InputDecoration(
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
                                  border: UnderlineInputBorder(),
                                  labelText: 'Password',
                                ),
                                obscureText: true,
                                controller: passwordController,
                                validator: (password) {
                                  bool isValid = password != null &&
                                      RegExp(r"^(?=.*\d)(?=.*[.!@#$%^&*])(?=.*[a-z])(?=.*[A-Z]).{8,}$")
                                          .hasMatch(password);
                                  return isValid
                                      ? null
                                      : "Please enter a valid password";
                                },
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              SizedBox(
                                width: double.infinity,
                                height: 40,
                                child: ElevatedButton(
                                  onPressed: isLoading ? null : _signupHandler,
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                        const Color.fromARGB(255, 12, 175, 96),
                                      ),
                                      shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(25),
                                        ),
                                      )),
                                  child: const Text(
                                    "Signup",
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
                                  const Text("Already have an account?"),
                                  TextButton(
                                    onPressed: () => Navigator.of(context)
                                        .pushReplacementNamed(
                                            LoginScreen.routeName),
                                    child: const Text("Login"),
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
