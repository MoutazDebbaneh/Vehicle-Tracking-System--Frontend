import 'dart:convert';

import 'package:flutter/material.dart';

import '../services/http_client.dart';

class Ride {
  final String id;
  final String title;
  final String creator;
  final dynamic startPoint;
  final dynamic endPoint;

  bool? isPublic;
  bool? isActive;
  bool? isFinished;

  String? vehicle;
  String? accessKey;
  bool? isRepeatitive;
  dynamic repeatition;
  List<dynamic>? keyPoints;
  List<dynamic>? drivers;
  String? oneTimeDate;

  Ride({
    required this.id,
    required this.title,
    required this.creator,
    required this.startPoint,
    required this.endPoint,
    this.isPublic,
    this.vehicle,
    this.isActive,
    this.isFinished,
    this.accessKey,
    this.isRepeatitive,
    this.repeatition,
    this.keyPoints,
    this.drivers,
    this.oneTimeDate,
  });

  factory Ride.fromJson(Map<String, dynamic> json) {
    return Ride(
        id: json['_id'],
        title: json['title'],
        creator: json['creator'],
        startPoint: json['start_point'],
        endPoint: json['end_point'],
        isPublic: json['is_public'],
        vehicle: json['vehicle'],
        isActive: json['is_active'],
        isFinished: json['is_finished'],
        accessKey: json['access_key'],
        isRepeatitive: json['is_repeatitive'],
        repeatition: json['repeatition'],
        keyPoints: json['key_points'],
        drivers: json['drivers'],
        oneTimeDate: json['one_time_date']);
  }

  static Future<List<Ride>> getRides(
      String type, GlobalKey<RefreshIndicatorState>? key) async {
    if (key != null) {
      key.currentState?.show();
    }
    try {
      final res = await HTTPClient.sendRequest(
        method: 'get',
        path: 'ride/$type',
        payload: {},
        queryParameters: null,
      );
      List<dynamic> body = jsonDecode(res.body)['rides'];

      List<Ride> rides = body
          .map(
            (dynamic item) => Ride.fromJson(item),
          )
          .toList();

      return rides;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<Ride?> addRide(Map rideData) async {
    try {
      final res = await HTTPClient.sendRequest(
        method: 'post',
        path: 'ride/add',
        payload: rideData,
        queryParameters: null,
      );

      return Ride.fromJson(jsonDecode(res.body));
    } catch (e) {
      print(e.toString());
      rethrow;
    }
  }

  static Future<bool?> deleteRide(String rideId) async {
    try {
      await HTTPClient.sendRequest(
        method: 'delete',
        path: 'ride/delete/$rideId',
        payload: {},
        queryParameters: null,
      );

      return true;
    } catch (e) {
      print(e.toString());
      rethrow;
    }
  }

  static Future<bool?> addPrivateRide(Map payload) async {
    try {
      await HTTPClient.sendRequest(
        method: 'patch',
        path: 'ride/addPrivateRide',
        payload: payload,
        queryParameters: null,
      );

      return true;
    } catch (e) {
      print(e.toString());
      rethrow;
    }
  }

  static Future<bool?> addDriver(Map payload) async {
    try {
      await HTTPClient.sendRequest(
        method: 'post',
        path: 'ride/addDriver',
        payload: payload,
        queryParameters: null,
      );

      return true;
    } catch (e) {
      print(e.toString());
      rethrow;
    }
  }
}
