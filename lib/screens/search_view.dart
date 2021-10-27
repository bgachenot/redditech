import 'package:flutter/material.dart';
import 'package:outline_search_bar/outline_search_bar.dart';
import 'package:redditech/helpers/network.dart';
import 'package:redditech/model/subreddit_search.dart';

class SearchView extends StatefulWidget {
  const SearchView({Key? key}) : super(key: key);

  @override
  _SearchViewState createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final NetworkHelper _networkHelper = NetworkHelper();
  List<SubRedditSearch> _subReddits = [];

  Future<void> getSubreddits(query) async {
    _subReddits = await _networkHelper.fetchSubreddits(query);
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
          Container(
            child: OutlineSearchBar(
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
          ),
          ListView.builder(
              itemCount: _subReddits.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return Card(
                  child: Text(_subReddits.elementAt(index).name),
                );
              }),
        ],
      ),
    );
  }
}
