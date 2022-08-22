import 'dart:async';

import 'package:flutter/material.dart';
import 'package:vtracker/models/ride.dart';

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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.green,
          content: Row(
            children: const [
              Icon(Icons.done),
              SizedBox(
                width: 6,
              ),
              Flexible(
                  child: Text('Ride added to your private rides successfully'))
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
                      )),
                )),
    );
  }
}
