import 'package:flutter/material.dart';
import 'package:redditech/helpers/network.dart';
import 'package:redditech/helpers/utils.dart';
import 'package:redditech/model/subreddit.dart';

class SubRedditView extends StatefulWidget {
  const SubRedditView({Key? key}) : super(key: key);

  @override
  _SubRedditViewState createState() => _SubRedditViewState();
}

class _SubRedditViewState extends State<SubRedditView> {
  final NetworkHelper _networkHelper = NetworkHelper();
  Map _data = {};
  late SubReddit _subreddit;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    //_scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    //_scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  Widget _getAction() {
    if (_subreddit.user_is_subscriber == false) {
      return InkWell(
        onTap: () async {
          try {
            _subreddit.user_is_subscriber = await _networkHelper
                .subRedditSubscription(_subreddit.name, true);
          } on ExceptionLoginInvalid {
            Navigator.pushReplacementNamed(context, '/login',
                arguments: {'error': 'Authentication expired.'});
          }
          setState(() {});
        },
        child: Row(
          children: const [
            Icon(Icons.add),
            Text('follow', style: TextStyle(fontSize: 16)),
            Padding(padding: EdgeInsets.all(8)),
          ],
        ),
      );
    }
    return InkWell(
      onTap: () async {
        try {
          _subreddit.user_is_subscriber = await _networkHelper
              .subRedditSubscription(_subreddit.name, false);
        } on ExceptionLoginInvalid {
          Navigator.pushReplacementNamed(context, '/login',
              arguments: {'error': 'Authentication expired.'});
        }
        setState(() {});
      },
      child: Row(
        children: const [
          Icon(Icons.remove),
          Text('unfollow', style: TextStyle(fontSize: 16)),
          Padding(padding: EdgeInsets.all(8)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _data = _data.isNotEmpty
        ? _data
        : ModalRoute.of(context)!.settings.arguments as Map;
    _subreddit = _data['subreddit'];
    return Scaffold(
      appBar: AppBar(
        title: Text(_subreddit.display_name_prefixed),
        actions: [
          _getAction(),
        ],
      ),
      body: Scrollbar(
        controller: _scrollController,
        child: Column(
          children: [
            Stack(
              children: [
                if (_subreddit.mobile_banner_image != null &&
                    _subreddit.mobile_banner_image != '')
                  Image.network(_subreddit.mobile_banner_image!),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(_subreddit.community_icon!),
                    radius: 60,
                  ),
                ),
              ],
            ),
            Text(_subreddit.title),
            Text(_subreddit.subscribers.toString() + ' members'),
            if (_subreddit.public_description != null)
              Text(_subreddit.public_description!),
          ],
        ),
      ),
    );
  }
}
