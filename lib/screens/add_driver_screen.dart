import 'dart:async';

import 'package:flutter/material.dart';
import 'package:vtracker/Services/utils.dart';
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

        Utils.showScaffoldMessage(
          context: context,
          msg: 'Driver added to your ride successfully',
          error: false,
        );

        _returnHome();
      }
    } on TimeoutException {
      Utils.showScaffoldMessage(
        context: context,
        msg: 'Request timeout exceeded',
        error: true,
      );
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      Utils.showScaffoldMessage(
        context: context,
        msg: e.toString().substring(11),
        error: true,
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  void _returnHome() {
    Navigator.of(context).pop();
    Navigator.of(context).pop();
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
