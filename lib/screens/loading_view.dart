import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;

class LoadingView extends StatefulWidget {
  const LoadingView({Key? key}) : super(key: key);

  @override
  _LoadingViewState createState() => _LoadingViewState();
}

class _LoadingViewState extends State<LoadingView> {
  void fetchUserData(token) async {
    var response = await http.get(
        Uri.parse('https://oauth.reddit.com/api/v1/me'),
        headers: {'authorization': 'bearer ' + token});
  }

  void _load() async {
    final storage = new FlutterSecureStorage();
    String? _accessToken = await storage.read(key: 'access_token');

    if (_accessToken == null) {
      await storage.deleteAll();
      Navigator.pushReplacementNamed(context, '/login', arguments: {'error': ''});
    }
    Navigator.pushReplacementNamed(context, '/main');
  }

  @override
  Widget build(BuildContext context) {
    _load();
    const spinKit = SpinKitRotatingCircle(
      color: Colors.deepOrange,
      size: 200,
    );
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Loading data",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Column(children: const [
        SizedBox(
          height: 200,
        ),
        spinKit,
        SizedBox(
          height: 150,
        ),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text("The application will start in a few seconds..."),
        ),
      ]),
    );
  }
}
