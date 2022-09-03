import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:vtracker/Services/map_controller.dart';
import 'package:vtracker/Services/utils.dart';
import 'package:vtracker/config.dart';
import 'package:vtracker/models/instance.dart';
import 'dart:async';
import 'dart:typed_data';

import 'package:vtracker/models/ride.dart';
import 'package:vtracker/screens/home_screen.dart';

class ViewInstanceScreen extends StatefulWidget {
  final Ride ride;
  final RideInstance rideInstance;
  final bool isActive;
  const ViewInstanceScreen(this.ride, this.rideInstance, this.isActive,
      {Key? key})
      : super(key: key);

  @override
  State<ViewInstanceScreen> createState() => _ViewInstanceScreenState();
}

class _ViewInstanceScreenState extends State<ViewInstanceScreen> {
  GoogleMapController? googleMapController;

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
  BitmapDescriptor locationAIcon = BitmapDescriptor.defaultMarker;

  StreamSubscription? _locationSubscription;

  late final Uint8List curIcon;

  Marker? curLocationMarker;

  List<dynamic> path = [];

  Timer? timer;

  void _returnHome() {
    Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
  }

  Future<bool?> _fetchLocation() async {
    try {
      RideInstance instance = await RideInstance.get(widget.rideInstance.id);
      if (instance.endDate != null && instance.endDate!.isNotEmpty) {
        _returnHome();

        Utils.showScaffoldMessage(
          context: context,
          msg: 'Ride ended',
          error: false,
        );
      }
      if (instance.path != null && instance.path!.isNotEmpty) {
        setState(() {
          path = instance.path!;
        });
      }
    } catch (e) {
      print(e.toString());
      return false;
    }
    return true;
  }

  void _updateMap() {
    setState(() {
      if (path.isNotEmpty) {
        currentLocation = LocationData.fromMap({
          "latitude": double.parse(path.last['latitude']['\$numberDecimal']),
          "longitude": double.parse(path.last['longitude']['\$numberDecimal']),
          "accuracy": double.parse(path.last['accuracy']['\$numberDecimal']),
          "heading": double.parse(path.last['rotation']['\$numberDecimal']),
        });

        LatLng curLocationLatLng = LatLng(
          currentLocation!.latitude!,
          currentLocation!.longitude!,
        );

        for (var point in path) {
          LatLng latLng = LatLng(
            double.parse(point['latitude']['\$numberDecimal']),
            double.parse(point['longitude']['\$numberDecimal']),
          );
          if (!(polylineCoordinates.contains(latLng))) {
            polylineCoordinates.add(latLng);
          }
        }

        if (googleMapController == null) return;

        googleMapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              zoom: mapZoom,
              target: curLocationLatLng,
            ),
          ),
        );
      }
    });
  }

  void _checkForUpdates() async {
    bool? updatedFound = await _fetchLocation();
    if (updatedFound != null && updatedFound) {
      _updateMap();
    }
  }

  void _initMarkers() async {
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

  void _initLocations() {
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

  void _initTimer() {
    timer = Timer.periodic(
        Config.mapRefreshDuration, (Timer t) => _checkForUpdates());
  }

  void _loadCompleteMapData() async {
    try {
      RideInstance fullInstance =
          await RideInstance.get(widget.rideInstance.id);

      widget.rideInstance.path = fullInstance.path;
    } catch (e) {
      print(e.toString());
      Utils.showScaffoldMessage(
        context: context,
        msg: e.toString().substring(11),
        error: true,
      );
    }

    setState(() {
      currentLocation = LocationData.fromMap({
        "latitude": double.parse(
            widget.rideInstance.path!.first['latitude']['\$numberDecimal']),
        "longitude": double.parse(
            widget.rideInstance.path!.last['longitude']['\$numberDecimal']),
        "accuracy": double.parse(
            widget.rideInstance.path!.last['accuracy']['\$numberDecimal']),
        "heading": double.parse(
            widget.rideInstance.path!.last['rotation']['\$numberDecimal']),
      });

      path = widget.rideInstance.path!;
      polylineCoordinates = widget.rideInstance.path!
          .map(
            (e) => LatLng(
              double.parse(e['latitude']['\$numberDecimal']),
              double.parse(e['longitude']['\$numberDecimal']),
            ),
          )
          .toList();
    });
  }

  void _initMapData() {
    _initMarkers();
    if (widget.isActive) {
      _loadCompleteMapData();
      _initTimer();
    } else {
      _loadCompleteMapData();
    }
  }

  void _init() async {
    _initLocations();
    _initMapData();
  }

  @override
  void initState() {
    _init();
    super.initState();
  }

  @override
  void dispose() {
    if (_locationSubscription != null) {
      _locationSubscription!.cancel();
    }
    if (timer != null) {
      timer!.cancel();
    }
    if (googleMapController != null) {
      googleMapController!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
      ),
      body: currentLocation == null || currentLocation!.latitude == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  double.parse(
                    widget.ride.startPoint['latitude']['\$numberDecimal'],
                  ),
                  double.parse(
                    widget.ride.startPoint['longitude']['\$numberDecimal'],
                  ),
                ),
                zoom: mapZoom,
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
                widget.isActive
                    ? curLocationMarker = Marker(
                        markerId: const MarkerId("current"),
                        zIndex: 2,
                        flat: true,
                        draggable: false,
                        anchor: const Offset(0.5, 0.5),
                        rotation: currentLocation!.heading ?? 0.0,
                        icon: currentLocationIcon,
                        position: LatLng(
                          currentLocation!.latitude!,
                          currentLocation!.longitude!,
                        ),
                      )
                    : const Marker(markerId: MarkerId("empty")),
              },
              onMapCreated: (mapController) {
                googleMapController = mapController;
              },
              circles: widget.isActive
                  ? {
                      Circle(
                        circleId: const CircleId("car"),
                        radius: currentLocation!.accuracy! + 10,
                        zIndex: 1,
                        strokeColor: Colors.blue,
                        center: LatLng(currentLocation!.latitude!,
                            currentLocation!.longitude!),
                        fillColor: Colors.blue.withAlpha(70),
                      ),
                    }
                  : {},
            ),
    );
  }
}
