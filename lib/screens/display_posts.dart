import 'package:chewie/chewie.dart';
import 'package:chewie_audio/chewie_audio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:redditech/helpers/network.dart';
import 'package:redditech/helpers/utils.dart';
import 'package:redditech/model/posts.dart';
import 'package:redditech/widgets/Subreddit_icon.dart';
import 'package:redditech/widgets/loading_data.dart';
import 'package:redditech/widgets/video_widget.dart';
import 'package:video_player/video_player.dart';

class DisplayPosts extends StatefulWidget {
  final String endpoint;

  const DisplayPosts({Key? key, required this.endpoint}) : super(key: key);

  @override
  _DisplayPostsState createState() => _DisplayPostsState();
}

class _DisplayPostsState extends State<DisplayPosts> {
  final NetworkHelper _networkHelper = NetworkHelper();
  bool _initFinished = false;
  List<Posts> _posts = [];
  late ScrollController _scrollController;
  bool _isLoadingMore = false;

  Future<void> initPosts() async {
    try {
      _posts = await _networkHelper.fetchUserPosts(widget.endpoint);
    } on ExceptionLoginInvalid catch (e) {
      Navigator.pushReplacementNamed(context, '/login',
          arguments: {'error': 'Authentication expired.'});
    }
    _initFinished = true;
    setState(() {});
  }

  Future<void> loadMorePosts() async {
    try {
      _isLoadingMore = true;
      _posts.addAll(await _networkHelper.fetchMoreUserPosts(
          widget.endpoint, _posts.elementAt(_posts.length - 1).subreddit_id));
      _isLoadingMore = false;
    } on ExceptionLoginInvalid catch (e) {
      Navigator.pushReplacementNamed(context, '/login',
          arguments: {'error': 'Authentication expired.'});
    }
    _initFinished = true;
    setState(() {});
  }

  void _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      if (_isLoadingMore == false) {
        loadMorePosts();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    initPosts();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  Widget _displayText(index) {
    if (_posts.elementAt(index).selftext.length > 300) {
      return Column(
        children: [
          Text(_posts.elementAt(index).selftext, maxLines: 10),
          const Padding(padding: EdgeInsets.all(8)),
          const Text('Read more...',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      );
    } else {
      return Text(_posts.elementAt(index).selftext);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_initFinished == false) {
      return const LoadingDataScreen();
    } else {
      return RefreshIndicator(
        onRefresh: () {
          return initPosts();
        },
        child: Scrollbar(
          thickness: 7,
          isAlwaysShown: true,
          controller: _scrollController,
          child: ListView.separated(
            controller: _scrollController,
            itemCount: _posts.length,
            shrinkWrap: true,
            separatorBuilder: (context, index) => const Divider(
              color: Colors.blue,
              thickness: 1,
            ),
            itemBuilder: (context, index) {
              return Column(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/post',
                          arguments: {'post': _posts.elementAt(index)});
                    },
                    child: Column(
                      children: <Widget>[
                        ListTile(
                          leading: iconWidget(
                              _posts.elementAt(index).subReddit.community_icon,
                              _posts.elementAt(index).subReddit.icon_img),
                          title: Text(_posts
                              .elementAt(index)
                              .subReddit
                              .display_name_prefixed),
                          subtitle: Text('u/' + _posts.elementAt(index).author),
                          trailing: const Icon(Icons.arrow_forward),
                          onTap: () async {
                            Navigator.pushNamed(context, '/subreddit', arguments: {
                              'subreddit': _posts.elementAt(index).subReddit
                            });
                          },
                        ),
                        if (_posts.elementAt(index).all_awardings != null)
                          ListTile(
                            tileColor: Colors.grey[300],
                            leading: const Text('Show rewards'),
                            trailing: const Icon(Icons.arrow_forward),
                            onTap: () {},
                          ),
                        if (_posts.elementAt(index).is_video &&
                            _posts.elementAt(index).media!.reddit_video)
                          VideoWidget(
                            url: _posts.elementAt(index).media!.reddit_video_url!,
                            play: true,
                          ),
                        if (_posts.elementAt(index).post_hint != null &&
                            _posts.elementAt(index).post_hint == 'image')
                          Column(
                            children: [
                              ListTile(
                                title: Text(_posts.elementAt(index).title),
                                subtitle: Image.network(
                                    _posts.elementAt(index).preview!.source_url),
                              ),
                            ],
                          ),
                        _displayText(index),
                        const Padding(padding: EdgeInsets.all(5)),
                        ListTile(
                          title: Row(
                            children: [
                              const FaIcon(FontAwesomeIcons.commentAlt),
                              const Padding(
                                  padding: EdgeInsets.fromLTRB(8, 0, 0, 0)),
                              Text(prettyNumber(
                                  _posts.elementAt(index).num_comments)),
                              const Padding(
                                  padding: EdgeInsets.fromLTRB(8, 0, 0, 0)),
                              const FaIcon(FontAwesomeIcons.arrowAltCircleUp),
                              const Padding(
                                  padding: EdgeInsets.fromLTRB(8, 0, 0, 0)),
                              Text(prettyNumber(_posts.elementAt(index).ups)),
                              const Padding(
                                  padding: EdgeInsets.fromLTRB(8, 0, 0, 0)),
                              const FaIcon(FontAwesomeIcons.arrowAltCircleDown),
                              const Padding(
                                  padding: EdgeInsets.fromLTRB(8, 0, 0, 0)),
                              Text(prettyNumber(_posts.elementAt(index).downs)),
                              const Padding(
                                  padding: EdgeInsets.fromLTRB(16, 0, 0, 0)),
                              const FaIcon(FontAwesomeIcons.hourglass),
                              const Padding(
                                  padding: EdgeInsets.fromLTRB(8, 0, 0, 0)),
                              Text(difference(_posts.elementAt(index).created,
                                      false, true) +
                                  ' hours'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      );
    }
  }
}
