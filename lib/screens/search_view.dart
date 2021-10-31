import 'package:flutter/material.dart';
import 'package:outline_search_bar/outline_search_bar.dart';
import 'package:redditech/helpers/network.dart';
import 'package:redditech/helpers/utils.dart';
import 'package:redditech/model/subreddit.dart';
import 'package:redditech/model/subreddit_search.dart';
import 'package:redditech/widgets/subreddit_icon.dart';

class SearchView extends StatefulWidget {
  const SearchView({Key? key}) : super(key: key);

  @override
  _SearchViewState createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final NetworkHelper _networkHelper = NetworkHelper();
  List<SubRedditSearch> _subReddits = [];
  late ScrollController _scrollController;
  bool _isLoadingMore = false;
  late String _lastQuery;

  Future<void> getSubreddits() async {
    try {
      _subReddits = await _networkHelper.searchSubreddits(_lastQuery);
    } on ExceptionLoginInvalid {
      Navigator.pushReplacementNamed(context, '/login',
          arguments: {'_error': 'Authentication expired.'});
    }
    setState(() {});
  }

  Future<void> loadMoreSubreddits() async {
    try {
      _isLoadingMore = true;
      _subReddits.addAll(await _networkHelper.searchMoreSubreddits(_lastQuery, _subReddits.elementAt(_subReddits.length - 1).name));
      _isLoadingMore = false;
    } on ExceptionLoginInvalid {
      Navigator.pushReplacementNamed(context, '/login',
          arguments: {'error': 'Authentication expired.'});
    }
    setState(() {});
  }

  void _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      if (_isLoadingMore == false) {
        loadMoreSubreddits();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    super.dispose();
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
              _lastQuery = query;
              if (query.length >= 3) {
                getSubreddits();
              } else {
                setState(() {
                  _subReddits = [];
                });
              }
            },
            onClearButtonPressed: (query) {
              setState(() {
                _subReddits = [];
              });
            },
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Scrollbar(
                isAlwaysShown: true,
                controller: _scrollController,
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _subReddits.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () async {
                        try {
                          SubReddit _subreddit =
                              await _networkHelper.fetchSubredditData(
                                  _subReddits.elementAt(index).display_name);
                          Navigator.pushNamed(context, '/subreddit',
                              arguments: {'subreddit': _subreddit});
                        } on ExceptionLoginInvalid {
                          Navigator.pushReplacementNamed(context, '/login',
                              arguments: {'error': 'Authentication expired.'});
                        }
                      },
                      child: Row(
                        children: [
                          Stack(
                            children: [
                              subredditIcon(
                                  _subReddits.elementAt(index).community_icon,
                                  _subReddits.elementAt(index).icon_img),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(100, 0, 0, 0),
                                child: Text(
                                    _subReddits
                                        .elementAt(index)
                                        .display_name_prefixed,
                                    style:
                                        Theme.of(context).textTheme.headline6),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(100, 30, 0, 0),
                                child: Text(
                                  '${_subReddits.elementAt(index).subscribers} members',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey[700]),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
