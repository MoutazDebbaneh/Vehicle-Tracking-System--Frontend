import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:vtracker/Services/map_controller.dart';
import 'dart:async';
import 'dart:typed_data';

class MapScreen extends StatefulWidget {
  static const routeName = "/map";
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller = Completer();

  static const sourceLocation = LatLng(33.5543519, 36.316056);
  static const destination = LatLng(33.5483876, 36.3130311);

  // static const sourceLocation = LatLng(37.33500926, -122.03272188);
  // static const destination = LatLng(37.33429383, -122.06600055);

  final mapZoom = 19.0;

  List<LatLng> polylineCoordinates = [];
  LocationData? currentLocation;

  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;

  StreamSubscription? _locationSubscription;

  late final Uint8List curIcon;

  Marker? curLocationMarker;

  void getCurrentLocation() async {
    Location location = Location();

    location.getLocation().then((loc) {
      setState(() {
        currentLocation = loc;
      });
    });

    GoogleMapController googleMapController = await _controller.future;

    _locationSubscription = location.onLocationChanged.listen((newloc) {
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

  void getPolyPoints() async {
    List<LatLng> cords =
        await MapController.getPolyPoints(sourceLocation, destination);

    setState(() {
      polylineCoordinates += cords;
    });
  }

  void initMarkers() async {
    currentLocationIcon = await MapController.loadCustomMarkerIcon(
        'assets/images/car_icon.png', 60);
  }

  @override
  void initState() {
    getCurrentLocation();
    initMarkers();
    getPolyPoints();
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
            onPressed: () {},
            icon: const Icon(Icons.done),
            tooltip: 'End Ride',
          ),
        ],
      ),
      body: currentLocation == null
          ? const Center(
              child: Text('Loading'),
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
                const Marker(
                  markerId: MarkerId("source"),
                  position: sourceLocation,
                ),
                const Marker(
                  markerId: MarkerId("destination"),
                  position: destination,
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
                  radius: currentLocation!.accuracy! + 10,
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
