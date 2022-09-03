import 'dart:convert';

import 'package:vtracker/services/http_client.dart';
import 'package:vtracker/services/secure_storage.dart';
import 'package:vtracker/config.dart';
import 'package:vtracker/models/instance.dart';

import 'package:http/http.dart' as http;

class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String type;

  String? currentDrivingInstance;
  String? accessToken;
  String? refreshToken;

  static User? ownUser;
  static RideInstance? currentInstance;

  static SecureStorage secureStorage = SecureStorage();

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.type,
    this.accessToken,
    this.refreshToken,
    this.currentDrivingInstance,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      type: json['type'],
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
      currentDrivingInstance: json['current_driving_instance'],
    );
  }

  static login(String email, String password) async {
    await http
        .post(
          Uri.parse('${Config.serverURL}/api/auth/signin'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            // "Access-Control-Allow-Origin":
            //     "*", // Required for CORS support to work
          },
          body: jsonEncode(
            <String, String>{
              'email': email,
              'password': password,
            },
          ),
        )
        .timeout(Config.requestTimeoutDuration)
        .then((res) {
      if (res.statusCode == 200) {
        secureStorage.writeSecureData('email', email);
        secureStorage.writeSecureData('password', password);
        return ownUser = User.fromJson(jsonDecode(res.body));
      } else {
        String errorMsg =
            jsonDecode(res.body)['error'] ?? "Unexpected error occurred";
        throw Exception(errorMsg);
      }
    }, onError: (e) {
      print(e.toString());
      if (e.toString().startsWith('TimeoutException')) {
        throw Exception('Request timeout exceeded');
      }
      throw Exception(e.toString());
    });
  }

  static signup(
      String firstName, String lastName, String email, String password) async {
    await http
        .post(
          Uri.parse('${Config.serverURL}/api/auth/signup'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(
            <String, String>{
              'first_name': firstName,
              'last_name': lastName,
              'email': email,
              'password': password,
            },
          ),
        )
        .timeout(Config.requestTimeoutDuration)
        .then((res) async {
      if (res.statusCode == 200) {
        try {
          final newUser = await login(email, password);
          return newUser;
        } catch (e) {
          throw Exception(e.toString());
        }
      } else {
        String errorMsg =
            jsonDecode(res.body)['error'] ?? "Unexpected error occurred";
        throw Exception(errorMsg);
      }
    }, onError: (e) => {throw Exception("Request timeout exceeded")});
    return;
  }

  static Future<bool?> signout() async {
    try {
      print(ownUser!.refreshToken);
      await HTTPClient.sendRequest(
        method: 'delete',
        path: 'auth/signout',
        payload: {'refreshToken': ownUser!.refreshToken},
        queryParameters: null,
      );
      return true;
    } catch (e) {
      print(e.toString());
      rethrow;
    }
  }
}
