import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:vtracker/Services/map_controller.dart';
import 'package:vtracker/Services/utils.dart';
import 'package:vtracker/models/instance.dart';
import 'dart:async';
import 'dart:typed_data';

import 'package:vtracker/models/ride.dart';
import 'package:vtracker/models/user.dart';
import 'package:vtracker/screens/home_screen.dart';

class DriveScreen extends StatefulWidget {
  final Ride ride;
  final RideInstance rideInstance;
  const DriveScreen(this.ride, this.rideInstance, {Key? key}) : super(key: key);

  @override
  State<DriveScreen> createState() => _DriveScreenState();
}

class _DriveScreenState extends State<DriveScreen> {
  final Completer<GoogleMapController> _controller = Completer();

  late final LatLng sourceLocation;
  late final LatLng destination;
  final List<LatLng> keyPoints = [];
  final List<Marker> keyPointsMarkers = [];

  final mapZoom = 19.0;

  List<LatLng> polylineCoordinates = [];
  LocationData? currentLocation;

  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;

  StreamSubscription? _locationSubscription;

  late final Uint8List curIcon;

  Marker? curLocationMarker;

  void _handleEndRide() async {
    bool? confirmEnd = await Utils.showConfirmDialog(
      context: context,
      title: 'Confirm Ride End',
      content: 'Are you sure you want to end this ride?',
      confirmString: 'End',
    );

    if (confirmEnd == null || !confirmEnd) return;

    String curDate = DateFormat("yyyy-MM-dd hh:mm a").format(DateTime.now());
    try {
      Map payload = {'rideId': widget.ride.id, 'end_date': curDate};

      RideInstance? endedInstance =
          await RideInstance.end(payload, widget.rideInstance.id);

      if (endedInstance != null) {
        User.currentInstance = null;
        User.ownUser!.currentDrivingInstance = null;
        widget.ride.isActive = false;

        Utils.showScaffoldMessage(
          context: context,
          msg: 'Drive ended succesfully',
          error: false,
        );

        _returnHome();
      }
    } catch (e) {
      print(e.toString());
    }
  }

  void _returnHome() {
    Navigator.of(context).pop();
    Navigator.of(context).pop();
    Navigator.of(context).pushNamed(HomeScreen.routeName);
  }

  void _updateLocation(LocationData newloc) async {
    try {
      Map payload = {
        'latitude': newloc.latitude,
        'longitude': newloc.longitude,
        'rotation': newloc.heading,
        'accuracy': newloc.accuracy,
        'rideId': widget.ride.id
      };

      await RideInstance.updateLocation(payload, widget.rideInstance.id);
    } catch (e) {
      print(e.toString());
    }
  }

  void getCurrentLocation() async {
    Location location = Location();

    location.getLocation().then((loc) {
      _updateLocation(loc);
      setState(() {
        currentLocation = loc;
      });
    });

    GoogleMapController googleMapController = await _controller.future;

    _locationSubscription = location.onLocationChanged.listen((newloc) {
      _updateLocation(newloc);

      polylineCoordinates.add(LatLng(newloc.latitude!, newloc.longitude!));

      setState(() {
        currentLocation = newloc;

        googleMapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              zoom: mapZoom,
              target: LatLng(newloc.latitude!, newloc.longitude!),
            ),
          ),
        );
      });
      setState(() {});
    });
  }

  void initMarkers() async {
    if (widget.ride.vehicle != null && widget.ride.vehicle == "Bus") {
      currentLocationIcon = await MapController.loadCustomMarkerIcon(
          'assets/images/bus_icon.png', 80);
    } else {
      currentLocationIcon = await MapController.loadCustomMarkerIcon(
          'assets/images/car_icon.png', 60);
    }

    sourceIcon = await MapController.loadCustomMarkerIcon(
        'assets/images/location_a.png', 90);

    destinationIcon = await MapController.loadCustomMarkerIcon(
        'assets/images/location_b.png', 90);
  }

  void initLocations() {
    sourceLocation = LatLng(
      double.parse(widget.ride.startPoint['latitude']['\$numberDecimal']),
      double.parse(widget.ride.startPoint['longitude']['\$numberDecimal']),
    );

    destination = LatLng(
      double.parse(widget.ride.endPoint['latitude']['\$numberDecimal']),
      double.parse(widget.ride.endPoint['longitude']['\$numberDecimal']),
    );

    if (widget.ride.keyPoints != null) {
      for (var point in widget.ride.keyPoints!) {
        keyPoints.add(
          LatLng(
            double.parse(point['latitude']['\$numberDecimal']),
            double.parse(point['longitude']['\$numberDecimal']),
          ),
        );
      }
    }

    for (var i = 0; i < keyPoints.length; i++) {
      keyPointsMarkers.add(
        Marker(
          markerId: MarkerId("keypoint-$i"),
          position: keyPoints[i],
          infoWindow: InfoWindow(
            title: 'Key Point ${i + 1}',
            snippet: widget.ride.keyPoints![i]['address'],
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    initLocations();
    initMarkers();
    getCurrentLocation();
    super.initState();
  }

  @override
  void dispose() {
    if (_locationSubscription != null) {
      _locationSubscription!.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
        actions: [
          IconButton(
            onPressed: _handleEndRide,
            icon: const Icon(Icons.done),
            tooltip: 'End Ride',
          ),
        ],
      ),
      body: currentLocation == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  currentLocation!.latitude!,
                  currentLocation!.longitude!,
                ),
                zoom: 14.5,
              ),
              polylines: {
                Polyline(
                  polylineId: const PolylineId("route"),
                  points: polylineCoordinates,
                  color: Colors.red,
                ),
              },
              markers: {
                ...keyPointsMarkers,
                Marker(
                  markerId: const MarkerId("source"),
                  position: sourceLocation,
                  icon: sourceIcon,
                  infoWindow: InfoWindow(
                    title: 'Location A',
                    snippet: widget.ride.startPoint['address'],
                  ),
                ),
                Marker(
                  markerId: const MarkerId("destination"),
                  position: destination,
                  icon: destinationIcon,
                  infoWindow: InfoWindow(
                    title: 'Location B',
                    snippet: widget.ride.endPoint['address'],
                  ),
                ),
                curLocationMarker = Marker(
                  markerId: const MarkerId("current"),
                  zIndex: 2,
                  flat: true,
                  draggable: false,
                  anchor: const Offset(0.5, 0.5),
                  rotation: currentLocation!.heading!,
                  icon: currentLocationIcon,
                  position: LatLng(
                    currentLocation!.latitude!,
                    currentLocation!.longitude!,
                  ),
                ),
              },
              onMapCreated: (mapController) {
                _controller.complete(mapController);
              },
              circles: {
                Circle(
                  circleId: const CircleId("car"),
                  radius: currentLocation!.accuracy! >= 8
                      ? currentLocation!.accuracy!
                      : 8,
                  zIndex: 1,
                  strokeColor: Colors.blue,
                  center: LatLng(
                      currentLocation!.latitude!, currentLocation!.longitude!),
                  fillColor: Colors.blue.withAlpha(70),
                ),
              },
            ),
    );
  }
}
