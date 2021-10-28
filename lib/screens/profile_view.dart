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
  final ScrollController _controllerOne = ScrollController();

  Future<void> initProfile() async {
    try {
      _user = await _networkHelper.fetchUserData();
      _trophies = await _networkHelper.fetchUserTrophies();
    } on ExceptionLoginInvalid catch (e) {
      Navigator.pushReplacementNamed(context, '/login', arguments: {'error': 'Authentication expired.'});
    }
    _initFinished = true;

    DateTime _accountCreatedSince = DateTime.fromMillisecondsSinceEpoch(
        (_user.created * 1000).toInt(),
        isUtc: true);
    _createdAccountInDays =
        DateTime.now().difference(_accountCreatedSince).inDays;
    setState(() {});
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
          title: Text(_user.name),
          centerTitle: true,
        ),
        backgroundColor: Colors.grey[300],
        body: RefreshIndicator(
          onRefresh: () {
            return initProfile();
          },
          child: ListView(
            children: [
              Container(
                color: Colors.grey[600],
                child: Stack(
                  children: [
                    if(_user.banner == true) Image.network(_user.bannerURL),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(_user.iconURL),
                        radius: 60,
                      ),
                    ),
                  ],
                ),
              ),
              Text('description: ' + _user.description),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Karma: ' + _user.totalKarma.toString(),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
                  child: Text('Account created since ' +
                      _createdAccountInDays.toString() +
                      ' days'),
                ),
              ),
              Text('Trophies'),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  shrinkWrap: true,
                  controller: _controllerOne,
                  itemCount: _trophies.length,
                  itemBuilder: (context, index) {
                    var _trophyAge = 0;
                    if (_trophies.elementAt(index).granted_at != 99999999) {
                      _trophyAge = DateTime.now()
                          .difference(DateTime.fromMillisecondsSinceEpoch(
                              (_trophies.elementAt(index).granted_at *
                                  1000)))
                          .inDays;
                    }
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Image.network(
                                _trophies.elementAt(index).icon_70_url),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                  _trophies.elementAt(index).name),
                            ),
                            Align(
                                alignment: Alignment.bottomLeft,
                                child: Text(
                                  _trophyAge.toString() + ' days ago',
                                  style: const TextStyle(color: Colors.purple),
                                )),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      );
    }
  }
}
