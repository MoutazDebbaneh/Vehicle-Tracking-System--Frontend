import 'dart:async';

import 'package:flutter/material.dart';
import 'package:vtracker/models/ride.dart';

class AddDriverScreen extends StatefulWidget {
  final String rideId;
  const AddDriverScreen(this.rideId, {Key? key}) : super(key: key);

  @override
  State<AddDriverScreen> createState() => _AddDriverScreenState();
}

class _AddDriverScreenState extends State<AddDriverScreen> {
  final emailController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  bool isLoading = false;

  void _addDriverHandler() async {
    final isValidForm = formKey.currentState!.validate();
    if (!isValidForm) return;
    setState(() {
      isLoading = true;
    });

    try {
      bool? res = await Ride.addDriver(
          {'rideId': widget.rideId, 'userEmail': emailController.text});

      if (res == null || !res) {
        throw Exception('Operation failed');
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.green,
          content: Row(
            children: const [
              Icon(Icons.done),
              SizedBox(
                width: 6,
              ),
              Flexible(child: Text('Driver added to your ride successfully'))
            ],
          ),
        ));
      }
      on(TimeoutException) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red[300],
          content: Row(
            children: const [
              Icon(Icons.error),
              SizedBox(
                width: 6,
              ),
              Flexible(child: Text('Request timeout exceeded'))
            ],
          ),
        ));
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red[300],
        content: Row(
          children: [
            const Icon(Icons.error),
            const SizedBox(
              width: 6,
            ),
            Flexible(child: Text(e.toString().substring(11)))
          ],
        ),
      ));
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a driver'),
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.email),
                          border: UnderlineInputBorder(),
                          labelText: 'Driver email',
                        ),
                        keyboardType: TextInputType.text,
                        controller: emailController,
                        validator: (email) {
                          bool isValid = email != null &&
                              RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                  .hasMatch(email);
                          return isValid ? null : "Please enter a valid email";
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      ElevatedButton(
                        onPressed: _addDriverHandler,
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.green),
                          padding: MaterialStateProperty.all<EdgeInsets>(
                              const EdgeInsets.all(16)),
                        ),
                        child: const Text('Add Driver'),
                      )
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
