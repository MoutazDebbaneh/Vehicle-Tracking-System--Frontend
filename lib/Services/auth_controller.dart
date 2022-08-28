import 'package:flutter/material.dart';

import 'package:vtracker/Services/secure_storage.dart';
import 'package:vtracker/Services/utils.dart';
import 'package:vtracker/models/user.dart';

class AuthController {
  static final SecureStorage secureStorage = SecureStorage();

  static Future<bool> login(
      String email, String password, BuildContext context) async {
    try {
      await User.login(email, password);
    } catch (e) {
      Utils.showScaffoldMessage(
        context: context,
        msg: e.toString().substring(11),
        error: true,
      );
    }
    return User.ownUser != null;
  }

  static Future<bool> checkIfAlreadyLoggedIn(BuildContext context) async {
    var email = await secureStorage.readSecureData('email');
    var password = await secureStorage.readSecureData('password');

    if (email == null || password == null) {
      return false;
    }

    return (await login(email, password, context));
  }

  static Future<bool> signup(
      {required firstName,
      required lastName,
      required email,
      required password,
      required BuildContext context}) async {
    try {
      await User.signup(firstName, lastName, email, password);
    } catch (e) {
      Utils.showScaffoldMessage(
        context: context,
        msg: e.toString().substring(11),
        error: true,
      );
    }
    return User.ownUser != null;
  }

  static Future<bool> signout(BuildContext context) async {
    try {
      bool? signedOut = await User.signout();
      if (signedOut != null && signedOut == true) {
        User.ownUser = null;
        await secureStorage.deleteSecureData('email');
        await secureStorage.deleteSecureData('password');
      }
    } catch (e) {
      Utils.showScaffoldMessage(
        context: context,
        msg: e.toString().substring(11),
        error: true,
      );
    }
    return User.ownUser == null;
  }
}
