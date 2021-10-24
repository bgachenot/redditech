import 'package:flutter/material.dart';
import 'package:redditech/widgets/navigation_bar.dart';

class MainView extends StatefulWidget {
  const MainView({Key? key}) : super(key: key);

  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {

  @override
  Widget build(BuildContext context) {
    return const BottomNavigationBarController();
  }
}
