import 'package:flutter/material.dart';
import 'package:redditech/helpers/network.dart';

class RedditLoginView extends StatefulWidget {
  const RedditLoginView({Key? key}) : super(key: key);

  @override
  _RedditLoginViewState createState() => _RedditLoginViewState();
}

class _RedditLoginViewState extends State<RedditLoginView> {
  final _networkHelper = NetworkHelper();
  var _errorMsg = "";
  Map _data = {};

  void _login() async {
    try {
      await _networkHelper.loginExplicitGrantFlow();
      Navigator.pushReplacementNamed(context, "/main", arguments: {});
    } catch (e) {
      //TODO: Handle multi lines in order to display the error message to the end user.
      _errorMsg = e.toString();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    _data = _data.isNotEmpty
        ? _data
        : ModalRoute.of(context)!.settings.arguments as Map;
    _errorMsg = _data['error'];
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: const Text(
          "Login to Reddit",
        ),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            onTap: _login,
            child: Image.asset('assets/images/login_button.png'),
          ),
          if (_errorMsg != '')
            Text(
              _errorMsg,
              style: const TextStyle(color: Colors.red, fontSize: 18),
            ),
        ],
      ),
    );
  }
}
