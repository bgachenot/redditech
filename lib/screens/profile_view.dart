import 'package:flutter/material.dart';
import 'package:redditech/helpers/network.dart';
import 'package:redditech/helpers/utils.dart';
import 'package:redditech/model/trophies.dart';
import 'package:redditech/model/user.dart';
import 'package:redditech/widgets/loading_data.dart';
import 'dart:async';

class ProfileView extends StatefulWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _networkHelper = NetworkHelper();
  late User _user;
  late List<Trophies> _trophies;
  late int _createdAccountInDays;
  bool _initFinished = false;

  Future<void> initProfile() async {
    try {
      _user = await _networkHelper.fetchUserData();
      _trophies = await _networkHelper.fetchUserTrophies();
    } on ExceptionLoginInvalid {
      Navigator.pushReplacementNamed(context, '/login',
          arguments: {'error': 'Authentication expired.'});
    }
    _initFinished = true;

    DateTime _accountCreatedSince = DateTime.fromMillisecondsSinceEpoch(
        (_user.created * 1000).toInt(),
        isUtc: true);
    _createdAccountInDays =
        DateTime.now().difference(_accountCreatedSince).inDays;
    setState(() {});
  }

  Widget _profileImages() {
    if (_user.banner == false) {
      return Stack(
        children: [],
      );
    }
    return Stack(
      children: [
        Container(
          height: 100,
          decoration: BoxDecoration(
            color: Theme.of(context).highlightColor,
            image: DecorationImage(
              image: NetworkImage(_user.bannerURL),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 40, 0, 5),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  blurRadius: 6,
                  color: Colors.grey.shade900,
                  spreadRadius: 2,
                )
              ],
            ),
            child: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColorDark,
              backgroundImage: NetworkImage(_user.iconURL),
              radius: 50.0,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
              MediaQuery.of(context).size.width - 150, 110, 0, 0),
          child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/trophies');
              },
              child: const Text(
                'My trophies',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              )),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    initProfile();
  }

  @override
  Widget build(BuildContext context) {
    if (_initFinished == false) {
      return const LoadingDataScreen();
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text(_user.namePrefixed),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/userSettings', arguments: {});
              },
              icon: const Icon(Icons.settings),
            ),
            const Padding(padding: EdgeInsets.all(8)),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () {
            return initProfile();
          },
          child: Column(
            children: [
              _profileImages(),
              Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                elevation: 5.0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6.0, vertical: 12.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            const Text(
                              "Karma",
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontSize: 22.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(
                              height: 5.0,
                            ),
                            Text(
                              _user.totalKarma.toString(),
                              style: const TextStyle(
                                fontSize: 20.0,
                                color: Colors.black,
                              ),
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            const Text(
                              "Trophies",
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontSize: 22.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(
                              height: 5.0,
                            ),
                            Text(
                              _trophies.length.toString(),
                              style: const TextStyle(
                                fontSize: 20.0,
                                color: Colors.black,
                              ),
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            const Text(
                              "Cake Day",
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontSize: 22.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(
                              height: 5.0,
                            ),
                            Text(
                              _createdAccountInDays.toString(),
                              style: const TextStyle(
                                fontSize: 20.0,
                                color: Colors.black,
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(6),
              ),
              const Text(
                "Bio:",
                style: TextStyle(
                  color: Colors.redAccent,
                  fontStyle: FontStyle.normal,
                  fontSize: 28.0,
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(6),
              ),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(6),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Text(
                        _user.description,
                        style: const TextStyle(
                          fontSize: 22.0,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w300,
                          color: Colors.black,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
