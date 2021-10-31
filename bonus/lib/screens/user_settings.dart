import 'package:flutter/material.dart';
import 'package:redditech/helpers/network.dart';
import 'package:redditech/helpers/utils.dart';
import 'package:redditech/model/preferences.dart';
import 'package:redditech/widgets/loading_data.dart';
import 'package:rolling_switch/rolling_switch.dart';

class UserSettingsView extends StatefulWidget {
  const UserSettingsView({Key? key}) : super(key: key);

  @override
  _UserSettingsViewState createState() => _UserSettingsViewState();
}

class _UserSettingsViewState extends State<UserSettingsView> {
  final _networkHelper = NetworkHelper();
  late UserPreferencies _userPreferencies;
  bool _initFinished = false;
  Map _data = {};
  bool modalroute = false;
  String? _errorMsg;

  Future<void> initProfile() async {
    try {
      _userPreferencies = await _networkHelper.fetchUserPrefs();
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

  Widget _createChoise(String text, String keyName, dynamic keyValue) {
    return Row(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width - 180,
          child: Text(
            text,
            textAlign: TextAlign.center,
            softWrap: true,
            style: Theme.of(context).textTheme.subtitle1,
          ),
        ),
        const Padding(padding: EdgeInsets.fromLTRB(25, 0, 0, 0)),
        RollingSwitch.icon(
          initialState: keyValue,
          onChanged: (bool state) async {
            try {
              if (await _networkHelper.patchUserPrefs(keyName, state) != true) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    '/userSettings', ModalRoute.withName('/main'), arguments: {
                  'error':
                      'Something unexpected happened...\nCould not change your settings.'
                });
              }
              _errorMsg = null;
              setState(() {});
            } on ExceptionLoginInvalid {
              Navigator.pushReplacementNamed(context, '/login',
                  arguments: {'error': 'Authentication expired.'});
            }
          },
          rollingInfoRight: const RollingIconInfo(
            icon: Icons.check,
            text: Text('Yes'),
          ),
          rollingInfoLeft: const RollingIconInfo(
            icon: Icons.close,
            backgroundColor: Colors.grey,
            text: Text('No'),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (modalroute == false) {
      _data = ModalRoute.of(context)!.settings.arguments as Map;
      _errorMsg = _data.containsKey('error') ? _data['error'] : null;
      _data = {};
      modalroute = true;
    }
    if (_initFinished == false) {
      return const LoadingDataScreen();
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Your settings',
            style: Theme.of(context).textTheme.headline5,
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              _createChoise('Allow people to follow you', 'enable_followers',
                  _userPreferencies.enable_followers),
              const SizedBox(height: 10),
              _createChoise('Show up in search results', 'hide_from_robots',
                  _userPreferencies.hide_from_robots),
              const SizedBox(height: 10),
              _createChoise(
                  'Personalize all of Reddit based on the outbound links you click on',
                  'allow_clicktracking',
                  _userPreferencies.allow_clicktracking),
              const SizedBox(height: 10),
              _createChoise(
                  'Personalize ads based on information from our partners',
                  'third_party_data_personalized_ads',
                  _userPreferencies.third_party_data_personalized_ads),
              const SizedBox(height: 10),
              _createChoise(
                  'Personalize ads based on your activity with our partners',
                  'third_party_site_data_personalized_ads',
                  _userPreferencies.third_party_site_data_personalized_ads),
              const SizedBox(height: 10),
              _createChoise(
                  'Personalize recommendations based on your general location',
                  'show_location_based_recommendations',
                  _userPreferencies.show_location_based_recommendations),
              const SizedBox(height: 10),
              _createChoise(
                  'Personalize recommendations based on your activity with our partners',
                  'third_party_site_data_personalized_content',
                  _userPreferencies.third_party_site_data_personalized_content),
              const SizedBox(height: 10),
              ElevatedButton(
                  onPressed: () async {
                    await _networkHelper.disconnectUser();
                    Navigator.pushNamed(context, '/');
                  },
                  child: const Text(
                    'Disconnect from Reddit',
                    style: TextStyle(fontSize: 18),
                  )),
              (_errorMsg != null)
                  ? Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Text(
                        _errorMsg!,
                        style: const TextStyle(fontSize: 20, color: Colors.red),
                      ),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        ),
      );
    }
  }
}
