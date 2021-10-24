import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:redditech/model/user.dart';
import 'package:http/http.dart' as http;
import 'package:redditech/widgets/loading_data.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late final User _user;
  late final List<dynamic> _trophies;
  late final _createdAccountInDays;
  var _initFinished = false;
  final ScrollController _controllerOne = ScrollController();

  Future<void> fetchUserTrophies(token) async {
    var response = await http.get(
        Uri.parse('https://oauth.reddit.com/api/v1/me/trophies?raw_json=1'),
        headers: {
          'authorization': 'bearer ' + token,
          'User-Agent':
              'android:eu.epitech.redditech.redditech:v0.0.1 (by /u/M0nkeyPyth0n)',
        });
    Map<String, dynamic> resp = jsonDecode(response.body);
    _trophies = resp['data']['trophies'];
    _trophies.forEach((element) {
      print(element);
    });
  }

  Future<User> fetchUserData(token) async {
    var response = await http.get(
        Uri.parse('https://oauth.reddit.com/api/v1/me?raw_json=1'),
        headers: {
          'authorization': 'bearer ' + token,
          'User-Agent':
              'android:eu.epitech.redditech.redditech:v0.0.1 (by /u/M0nkeyPyth0n)',
        });
    Map<String, dynamic> resp = jsonDecode(response.body);

    User user = User(
        name: resp['name'],
        namePrefixed: resp['subreddit']['display_name_prefixed'],
        description: resp['subreddit']['description'],
        banner:
            (resp['subreddit']['banner_img'] as String).isEmpty ? false : true,
        bannerURL: resp['subreddit']['banner_img'],
        iconURL: resp['icon_img'],
        totalKarma: resp['total_karma'],
        created: resp['created_utc']);
    return user;
  }

  void initProfile() async {
    final _storage = new FlutterSecureStorage();
    final _accessToken = await _storage.read(key: 'access_token');
    _user = await fetchUserData(_accessToken);
    await fetchUserTrophies(_accessToken);
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
          title: const Text("Profile"),
          centerTitle: true,
        ),
        backgroundColor: Colors.grey[300],
        body: Column(
          children: [
            Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                    image: NetworkImage(_user.iconURL),
                    fit: BoxFit.fill,
                    scale: 1),
              ),
            ),
            Text(_user.name),
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
                  var _trophyAge = DateTime.now()
                      .difference(DateTime.fromMillisecondsSinceEpoch(
                          (_trophies.elementAt(index)['data']['granted_at'] * 1000)))
                      .inDays;
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Image.network(
                              _trophies.elementAt(index)['data']['icon_70']),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(_trophies.elementAt(index)['data']['name']),
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
      );
    }
  }
}
