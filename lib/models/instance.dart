import 'dart:convert';

import 'package:flutter/material.dart';

import '../Services/http_client.dart';

class RideInstance {
  final String id;
  final String rideId;
  final String driverId;
  List<dynamic>? path;
  String startDate;
  String? endDate;

  RideInstance({
    required this.id,
    required this.rideId,
    required this.driverId,
    required this.startDate,
    this.endDate,
    this.path,
  });

  factory RideInstance.fromJson(Map<String, dynamic> json) {
    return RideInstance(
      id: json['_id'],
      rideId: json['ride_id'],
      driverId: json['driver_id'],
      path: json['path'],
      startDate: json['start_date'],
      endDate: json['end_date'],
    );
  }

  static Future<RideInstance?> startInstance(
      Map instanceData, String rideId) async {
    try {
      final res = await HTTPClient.sendRequest(
        method: 'post',
        path: 'rideInstance/start/$rideId',
        payload: instanceData,
        queryParameters: null,
      );

      return RideInstance.fromJson(jsonDecode(res.body));
    } catch (e) {
      print(e.toString());
      rethrow;
    }
  }

  static Future<RideInstance?> updateLocation(
      Map instanceData, String instanceId) async {
    try {
      final res = await HTTPClient.sendRequest(
        method: 'patch',
        path: 'rideInstance/updateLocation/$instanceId',
        payload: instanceData,
        queryParameters: null,
      );

      return RideInstance.fromJson(jsonDecode(res.body));
    } catch (e) {
      print(e.toString());
      rethrow;
    }
  }

  static Future<RideInstance?> end(Map instanceData, String instanceId) async {
    try {
      final res = await HTTPClient.sendRequest(
        method: 'patch',
        path: 'rideInstance/end/$instanceId',
        payload: instanceData,
        queryParameters: null,
      );

      return RideInstance.fromJson(jsonDecode(res.body));
    } catch (e) {
      print(e.toString());
      rethrow;
    }
  }

  static Future<List<RideInstance>> getInstances(
      String rideId, GlobalKey<RefreshIndicatorState>? key) async {
    if (key != null) {
      key.currentState?.show();
    }
    try {
      final res = await HTTPClient.sendRequest(
        method: 'get',
        path: 'rideInstance/getInstances/$rideId',
        payload: {},
        queryParameters: null,
      );
      var body = jsonDecode(res.body);

      List<dynamic> instancesEncoded = body['instances'];

      if (body['count'] == 0) return [];

      List<RideInstance> instances = instancesEncoded
          .map(
            (dynamic item) => RideInstance.fromJson(item),
          )
          .toList();

      return instances;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<RideInstance> get(String instanceId) async {
    try {
      final res = await HTTPClient.sendRequest(
        method: 'get',
        path: 'rideInstance/$instanceId',
        payload: {},
        queryParameters: null,
      );

      return RideInstance.fromJson(jsonDecode(res.body));
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
