import 'package:flutter/material.dart';
import 'package:redditech/model/subreddit.dart';

class SubRedditView extends StatefulWidget {
  const SubRedditView({Key? key}) : super(key: key);

  @override
  _SubRedditViewState createState() => _SubRedditViewState();
}

class _SubRedditViewState extends State<SubRedditView> {
  Map _data = {};
  late SubReddit _subreddit;

  @override
  Widget build(BuildContext context) {
    _data = _data.isNotEmpty
        ? _data
        : ModalRoute.of(context)!.settings.arguments as Map;
    _subreddit = _data['subreddit'];
    return Scaffold(
      appBar: AppBar(
        title: Text(_subreddit.display_name_prefixed),
      ),
      body: Column(
        children: [
          Stack(
            children: [
              if(_subreddit.mobile_banner_image != '') Image.network(_subreddit.mobile_banner_image),
              Align(
                alignment: Alignment.bottomLeft,
                child: CircleAvatar(
                  backgroundImage: NetworkImage(_subreddit.community_icon_url!),
                  radius: 60,
                ),
              ),
            ],
          ),
          Text(_subreddit.title),
          Text(_subreddit.subscribers.toString() + ' members'),
          Text(_subreddit.public_description),
        ],
      ),
    );
  }
}
