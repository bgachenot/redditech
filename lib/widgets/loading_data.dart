import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingDataScreen extends StatefulWidget {
  const LoadingDataScreen({Key? key}) : super(key: key);

  @override
  _LoadingDataScreenState createState() => _LoadingDataScreenState();
}

class _LoadingDataScreenState extends State<LoadingDataScreen> {
  String _waitingMessage = "Fetching data....";
  late Timer _timer;

  void handleTimeout() {
    setState(() {
      _waitingMessage = "Taking much time than expected...\n";
    });
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 5), handleTimeout);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const spinKit = SpinKitRotatingCircle(
      color: Colors.deepOrange,
      size: 200,
    );
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Column(children: [
        SizedBox(
          height: 200,
        ),
        spinKit,
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(_waitingMessage),
        ),
      ]),
    );
  }
}
