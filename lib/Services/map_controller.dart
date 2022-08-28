import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;

import 'package:vtracker/config.dart';

class MapController {
  static Future<List<LatLng>> getPolyPoints(
      LatLng sourceLocation, LatLng destination, List<LatLng> keyPoints) async {
    String pointsParam =
        'point=${sourceLocation.latitude},${sourceLocation.longitude}&';

    for (var point in keyPoints) {
      pointsParam += 'point=${point.latitude},${point.longitude}&';
    }

    pointsParam += 'point=${destination.latitude},${destination.longitude}';

    String url =
        'https://graphhopper.com/api/1/route?$pointsParam&key=${Config.graphHopperAPIKey}&points_encoded=false';

    try {
      http.Response response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 120));

      if (response.statusCode != 200) {
        throw Exception('Could not calculate route');
      }

      List<dynamic> cordsList =
          jsonDecode(response.body)['paths'][0]['points']['coordinates'];

      List<LatLng> polyPoints = [];

      for (List<dynamic> cord in cordsList) {
        polyPoints.add(LatLng(cord[1], cord[0]));
      }

      return polyPoints;
    } catch (e) {
      throw Exception(e.toString());
    }

    // for (List<dynamic> cord in body) {
    //   setState(() {
    //     polylineCoordinates.add(LatLng(cord[1] as double, cord[0] as double));
    //   });
    // }
  }

  static Future<BitmapDescriptor> loadCustomMarkerIcon(
      String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    var iconByteData =
        await fi.image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List icon = iconByteData!.buffer.asUint8List();
    return BitmapDescriptor.fromBytes(icon);
  }
}
