import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'dart:math';
import 'package:redditech/model/User.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ExceptionRandomString implements Exception {}

class ExceptionUserRefused implements Exception {}

const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
Random _rng = Random();

String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
    length, (_) => _chars.codeUnitAt(_rng.nextInt(_chars.length))));

Map<String, dynamic> parseRedditAuthorizationResponse(
    String _redditRawResponse) {
  final _redditSplitRawResponse = _redditRawResponse.split('&');
  var _redditRawJsonResponse = "{";
  for (int i = 0; i != _redditSplitRawResponse.length; i++) {
    var key = _redditSplitRawResponse[i].split('=')[0];
    var value = _redditSplitRawResponse[i].split('=')[1];

    _redditRawJsonResponse += '"$key": "$value"' +
        (i + 1 == _redditSplitRawResponse.length ? '}' : ',');
  }
  return jsonDecode(_redditRawJsonResponse);
}

class RedditLoginView extends StatefulWidget {
  const RedditLoginView({Key? key}) : super(key: key);

  @override
  _RedditLoginViewState createState() => _RedditLoginViewState();
}

class _RedditLoginViewState extends State<RedditLoginView> {
  final _clientID = 'fgEGy01xVvt_6kcaMDiI3w';
  final _redirectURI = 'me.app.local';
  final _callbackScheme = "://login";
  var _errorMsg = "";

  void _login() async {
    final _randomString = getRandomString(40);
    final authorizeUrl =
        Uri.https('www.reddit.com', '/api/v1/authorize.compact', {
      'client_id': _clientID,
      'response_type': 'token',
      'state': _randomString,
      'redirect_uri': _redirectURI + _callbackScheme,
      'scope': 'identity',
    });
    try {
      final _authenticateResult = await FlutterWebAuth.authenticate(
        url: authorizeUrl.toString(),
        callbackUrlScheme: _redirectURI,
        preferEphemeral: true,
      );
      final _redditRawResponse = Uri.parse(_authenticateResult).fragment;
      final _queryResult = parseRedditAuthorizationResponse(_redditRawResponse);

      //TODO: Handle other errors (client_id invalid, redirect_uri invalid)

      // If the user pressed the refuse button
      if (_queryResult['error'] == 'access_denied') {
        throw ExceptionUserRefused();
      }
      // if the state isn't equal to the random string we sent, then warn the user
      if (_queryResult['state'] != _randomString) {
        throw ExceptionRandomString();
      }
      _errorMsg = "";
      final storage = new FlutterSecureStorage();
      await storage.write(
          key: 'access_token', value: _queryResult['access_token']);

      Navigator.pushReplacementNamed(context, "/main", arguments: {});
    } on PlatformException catch (_) {
      _errorMsg = "Aborted by user";
    } on ExceptionUserRefused catch (_) {
      _errorMsg = "You refused the authentication. Please try again.";
    } on ExceptionRandomString catch (_) {
      _errorMsg = "Response from Reddit altered. Please try again.";
    } catch (e) {
      //TODO: Handle multi lines in order to display the error message to the end user.
      print(e.toString());
      //_errorMsg = e.toString();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Please login to Reddit",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Column(children: [
        const SizedBox(height: 250),
        Center(
          child: Text(
            _errorMsg,
            style: const TextStyle(color: Colors.red, fontSize: 18),
          ),
        ),
        Center(
          child: ElevatedButton(
            onPressed: _login,
            child: const Text("Login"),
          ),
        ),
      ]),
    );
  }
}
