import 'dart:async';

import 'package:flutter/material.dart';
import 'package:vtracker/Services/utils.dart';
import 'package:vtracker/models/ride.dart';
import 'package:vtracker/screens/home_screen.dart';

class AddPrivateRideScreen extends StatefulWidget {
  static const routeName = "/addPrivateRide";
  const AddPrivateRideScreen({Key? key}) : super(key: key);

  @override
  State<AddPrivateRideScreen> createState() => _AddPrivateRideScreenState();
}

class _AddPrivateRideScreenState extends State<AddPrivateRideScreen> {
  final titleController = TextEditingController();
  final accessKeyController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  bool isLoading = false;

  void _addPrivateRideHandler() async {
    final isValidForm = formKey.currentState!.validate();
    if (!isValidForm) return;
    setState(() {
      isLoading = true;
    });

    try {
      bool? res = await Ride.addPrivateRide({
        'title': titleController.text,
        'access_key': accessKeyController.text
      });

      if (res == null || !res) {
        throw Exception('Operation failed');
      } else {
        setState(() {
          isLoading = false;
        });

        Utils.showScaffoldMessage(
          context: context,
          msg: 'Ride added to your private rides successfully',
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
    Navigator.of(context).pushNamed(HomeScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a private ride'),
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
                          prefixIcon: Icon(Icons.title),
                          border: UnderlineInputBorder(),
                          labelText: 'Ride Title',
                        ),
                        keyboardType: TextInputType.text,
                        controller: titleController,
                        validator: (title) {
                          return title != null && title.trim().isNotEmpty
                              ? null
                              : "Title must not be empty";
                        },
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.password),
                          border: UnderlineInputBorder(),
                          labelText: 'Ride Access Key',
                        ),
                        keyboardType: TextInputType.visiblePassword,
                        controller: accessKeyController,
                        validator: (accessKey) {
                          return accessKey != null &&
                                  accessKey.trim().isNotEmpty
                              ? null
                              : "Access Key must not be empty";
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      ElevatedButton(
                        onPressed: _addPrivateRideHandler,
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.green),
                          padding: MaterialStateProperty.all<EdgeInsets>(
                              const EdgeInsets.all(16)),
                        ),
                        child: const Text('Add Private Ride'),
                      )
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
