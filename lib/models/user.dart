import 'dart:convert';
import 'dart:io';

import 'package:vtracker/config.dart';

import 'package:http/http.dart' as http;

class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String type;

  String? accessToken;
  String? refreshToken;

  static User? ownUser;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.type,
    this.accessToken,
    this.refreshToken,
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
    );
  }

  static login(String email, String password) async {
    await http
        .post(
          Uri.parse('${Config.serverURL}/api/auth/signin'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(
            <String, String>{
              'email': email,
              'password': password,
            },
          ),
        )
        .timeout(const Duration(seconds: 20))
        .then((res) {
      if (res.statusCode == 200) {
        return ownUser = User.fromJson(jsonDecode(res.body));
      } else {
        String errorMsg =
            jsonDecode(res.body)['error'] ?? "Unexpected error occurred";
        throw Exception(errorMsg);
      }
    }, onError: (e) => {throw Exception("Request timeout exceeded")});
    return;
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
        .timeout(const Duration(seconds: 20))
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
}
