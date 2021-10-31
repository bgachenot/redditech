import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingDataScreen extends StatefulWidget {
  const LoadingDataScreen({Key? key}) : super(key: key);

  @override
  _LoadingDataScreenState createState() => _LoadingDataScreenState();
}

class _LoadingDataScreenState extends State<LoadingDataScreen> {
  String _waitingMessage = "Fetching data...";
  late Timer _timer;

  void handleTimeout() {
    setState(() {
      _waitingMessage =
          "Fetching data is taking more time than expected...\nPlease check your network connection.\nTip: Wifi connections are more stable than cellular network.";
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
    const _spinKit = SpinKitSpinningLines(
      color: Colors.black,
      size: 160,
    );
    return Scaffold(
      body: Column(
        children: [
          const Expanded(
            child: _spinKit,
          ),
          Expanded(
            child: Text(
              _waitingMessage,
              style: const TextStyle(fontSize: 18, color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
