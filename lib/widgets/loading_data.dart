import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingDataScreen extends StatefulWidget {
  const LoadingDataScreen({Key? key}) : super(key: key);

  @override
  _LoadingDataScreenState createState() => _LoadingDataScreenState();
}

class _LoadingDataScreenState extends State<LoadingDataScreen> {
  @override
  Widget build(BuildContext context) {
    const spinKit = SpinKitRotatingCircle(
      color: Colors.deepOrange,
      size: 200,
    );
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Column(children: const [
        SizedBox(
          height: 200,
        ),
        spinKit,
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text("Fetching data...."),
        ),
      ]),
    );
  }
}
