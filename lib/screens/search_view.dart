import 'package:flutter/material.dart';
import 'package:outline_search_bar/outline_search_bar.dart';
import 'package:redditech/helpers/network.dart';
import 'package:redditech/helpers/utils.dart';
import 'package:redditech/model/subreddit.dart';
import 'package:redditech/model/subreddit_search.dart';
import 'package:redditech/widgets/Subreddit_icon.dart';

class SearchView extends StatefulWidget {
  const SearchView({Key? key}) : super(key: key);

  @override
  _SearchViewState createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final NetworkHelper _networkHelper = NetworkHelper();
  List<SubRedditSearch> _subReddits = [];

  Future<void> getSubreddits(query) async {
    try {
      _subReddits = await _networkHelper.fetchSubreddits(query);
    } on ExceptionLoginInvalid {
      Navigator.pushReplacementNamed(context, '/login',
          arguments: {'_error': 'Authentication expired.'});
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search for subreddits'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          OutlineSearchBar(
            hintText: 'Superstonk',
            maxLength: 21,
            onTypingFinished: (query) {
              getSubreddits(query);
            },
            onClearButtonPressed: (query) {
              setState(() {
                _subReddits = [];
              });
            },
          ),
          Expanded(
            child: ListView.builder(
                itemCount: _subReddits.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: iconWidget(_subReddits.elementAt(index).community_icon, _subReddits.elementAt(index).icon_img),
                    title: Text(_subReddits.elementAt(index).name),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () async {
                      SubReddit _subreddit =
                          await _networkHelper.fetchSubredditData(
                              _subReddits.elementAt(index).name);
                      Navigator.pushNamed(context, '/subreddit',
                          arguments: {'subreddit': _subreddit});
                    },
                  );
                }),
          ),
        ],
      ),
    );
  }
}
