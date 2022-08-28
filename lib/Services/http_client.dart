import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:vtracker/config.dart';
import 'package:vtracker/models/user.dart';

class HTTPClient {
  static const serverURL = Config.serverURL;

  static sendRequest({
    required String method,
    required String path,
    required payload,
    required queryParameters,
  }) async {
    final String formattedParams = formatQueryParameters(queryParameters);
    late final http.Response response;
    switch (method) {
      case 'get':
        response = await http.get(
          Uri.parse('$serverURL/api/$path$formattedParams'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer ${User.ownUser!.accessToken!}',
          },
        ).timeout(Config.requestTimeoutDuration,
            onTimeout: () => throw Exception('Request timeout exceeded'));
        break;
      case 'post':
        response = await http
            .post(
              Uri.parse('$serverURL/api/$path$formattedParams'),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
                'Authorization': 'Bearer ${User.ownUser!.accessToken!}',
              },
              body: jsonEncode(payload),
            )
            .timeout(Config.requestTimeoutDuration,
                onTimeout: () => throw Exception('Request timeout exceeded'));
        break;
      case 'patch':
        response = await http
            .patch(
              Uri.parse('$serverURL/api/$path$formattedParams'),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
                'Authorization': 'Bearer ${User.ownUser!.accessToken!}',
              },
              body: jsonEncode(payload),
            )
            .timeout(Config.requestTimeoutDuration,
                onTimeout: () => throw Exception('Request timeout exceeded'));
        break;
      case 'delete':
        response = await http
            .delete(
              Uri.parse('$serverURL/api/$path$formattedParams'),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
                'Authorization': 'Bearer ${User.ownUser!.accessToken!}',
              },
              body: jsonEncode(payload),
            )
            .timeout(Config.requestTimeoutDuration,
                onTimeout: () => throw Exception('Request timeout exceeded'));
        break;
      default:
    }

    if (response.statusCode == 200) {
      return response;
    } else if (response.statusCode == 403) {
      if (jsonDecode(response.body)['error'] == 'jwt expired') {
        print('jwt expired...reauthenticating..');
        final reAuthenticated = await _reAuthToken();
        if (reAuthenticated == true) {
          return sendRequest(
              method: method,
              path: path,
              payload: payload,
              queryParameters: queryParameters);
        } else {
          throw Exception('User session has expired');
        }
      } else {
        throw Exception(jsonDecode(response.body)['error'] ??
            'Unexpected auth error occurred');
      }
    } else {
      throw Exception(
          jsonDecode(response.body)['error'] ?? 'Unexpected error occurred');
    }
  }

  static String formatQueryParameters(params) {
    if (params == null) return '';
    String formattedParams = '?';
    params.forEach((key, value) {
      formattedParams += '$key=$value&';
    });
    formattedParams = formattedParams.substring(0, formattedParams.length - 1);
    return formattedParams.isEmpty ? '' : formattedParams;
  }

  static Future<bool> _reAuthToken() async {
    final response = await sendRequest(
      method: 'post',
      path: 'auth/regenerateAccessToken',
      payload: {"refreshToken": User.ownUser!.refreshToken!},
      queryParameters: {},
    );
    if (response.statusCode == 200) {
      User.ownUser!.accessToken = jsonDecode(response.body)['accessToken'];
      return true;
    }
    return false;
  }
}
