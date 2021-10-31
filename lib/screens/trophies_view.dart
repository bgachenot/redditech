import 'package:flutter/material.dart';
import 'package:redditech/helpers/network.dart';
import 'package:redditech/helpers/utils.dart';
import 'package:redditech/model/trophies.dart';
import 'package:redditech/widgets/loading_data.dart';

class TrophiesView extends StatefulWidget {
  const TrophiesView({Key? key}) : super(key: key);

  @override
  _TrophiesViewState createState() => _TrophiesViewState();
}

class _TrophiesViewState extends State<TrophiesView> {
  final ScrollController _controllerOne = ScrollController();
  final _networkHelper = NetworkHelper();
  late List<Trophies> _trophies;
  bool _initFinished = false;

  Future<void> initProfile() async {
    try {
      _trophies = await _networkHelper.fetchUserTrophies();
    } on ExceptionLoginInvalid {
      Navigator.pushReplacementNamed(context, '/login',
          arguments: {'error': 'Authentication expired.'});
    }
    _initFinished = true;
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
          title: const Text(
            "Your Trophies",
            style: TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: RefreshIndicator(
          onRefresh: () {
            return initProfile();
          },
          child: ListView(
            children: [
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  controller: _controllerOne,
                  itemCount: _trophies.length,
                  itemBuilder: (context, index) {
                    var _trophyAge = 0;
                    if (_trophies.elementAt(index).granted_at != 99999999) {
                      _trophyAge = DateTime.now()
                          .difference(DateTime.fromMillisecondsSinceEpoch(
                              (_trophies.elementAt(index).granted_at * 1000)))
                          .inDays;
                    }
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Stack(
                          children: [
                            Image.network(
                                _trophies.elementAt(index).icon_70_url),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(
                                    MediaQuery.of(context).size.width - 250,
                                    0,
                                    0,
                                    0),
                                child: Text(
                                  _trophies.elementAt(index).name,
                                  style: Theme.of(context).textTheme.headline6,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(
                                  MediaQuery.of(context).size.width - 100,
                                  55,
                                  0,
                                  0),
                              child: Text(
                                _trophyAge.toString() + ' days ago',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1!
                                    .copyWith(color: Colors.purple),
                              ),
                            ),
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
