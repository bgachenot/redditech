import 'package:chewie/chewie.dart';
import 'package:chewie_audio/chewie_audio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:redditech/helpers/network.dart';
import 'package:redditech/helpers/utils.dart';
import 'package:redditech/model/posts.dart';
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

  @override
  void initState() {
    super.initState();
    initPosts();
  }

  Widget _displayText(index) {
    if (_posts.elementAt(index).selftext.length > 300) {
      return Column(
        children: [
          Text(_posts.elementAt(index).selftext, maxLines: 10),
          Text('[...]', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
      return ListView.separated(
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
                      leading: Image.network(_posts
                              .elementAt(index)
                              .subReddit
                              .community_icon ??
                          _posts.elementAt(index).subReddit.icon_img!),
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
      );
    }
  }
}
