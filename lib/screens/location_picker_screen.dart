import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:open_street_map_search_and_pick/open_street_map_search_and_pick.dart';

class LocationPickerScreen extends StatelessWidget {
  final LocationData currentLocation;
  const LocationPickerScreen(this.currentLocation, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Pick a location')),
        floatingActionButton: null,
        body: OpenStreetMapSearchAndPick(
          center:
              LatLong(currentLocation.latitude!, currentLocation.longitude!),
          buttonColor: const Color.fromARGB(255, 12, 175, 96),
          buttonText: 'Pick Location',
          onPicked: (pickedData) {
            Navigator.of(context).pop(pickedData);
          },
        ));
  }
}
