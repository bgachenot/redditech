import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'dart:math';

class ExceptionRandomString implements Exception {}

const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
Random _rng = Random();

String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
    length, (_) => _chars.codeUnitAt(_rng.nextInt(_chars.length))));

dynamic parseRedditAuthorizationResponse(List<String> _redditRawResponse) {
  var tokenString = "{";
  for (int i = 0; i != _redditRawResponse.length; i++) {
    var key = _redditRawResponse[i].split('=')[0];
    var value = _redditRawResponse[i].split('=')[1];

    tokenString +=
        '"$key": "$value"' + (i + 1 == _redditRawResponse.length ? '}' : ',');
  }
  return jsonDecode(tokenString);
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
      final _redditRawResponse =
          Uri.parse(_authenticateResult).fragment.split('&');
      final _queryResult = parseRedditAuthorizationResponse(_redditRawResponse);

      // if the state isn't equal to the random string we sent,
      if (_queryResult['state'] != _randomString) {
        throw ExceptionRandomString();
      }
      //TODO: store the access_token to a local secure file
      Navigator.pushReplacementNamed(context, "/main", arguments: {});
    } on PlatformException catch (_) {
      _errorMsg = "Aborted by user";
    } on ExceptionRandomString catch (_) {
      _errorMsg = "Response from Reddit altered. Please try again.";
    } catch (e) {
      _errorMsg = e.toString();
    }
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
            "Error: " + _errorMsg,
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
