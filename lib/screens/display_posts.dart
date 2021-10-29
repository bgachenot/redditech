import 'package:chewie/chewie.dart';
import 'package:chewie_audio/chewie_audio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:redditech/helpers/network.dart';
import 'package:redditech/helpers/utils.dart';
import 'package:redditech/model/posts.dart';
import 'package:redditech/widgets/loading_data.dart';
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
                  Navigator.pushNamed(context, '/subreddit', arguments: {
                    'subreddit': _posts.elementAt(index).subReddit
                  });
                },
                child: Column(
                  children: <Widget>[
                    ListTile(
                      leading: Image.network(_posts
                              .elementAt(index)
                              .subReddit
                              .community_icon_url ??
                          _posts.elementAt(index).subReddit.icon_img),
                      title: Text(_posts
                          .elementAt(index)
                          .subReddit
                          .display_name_prefixed),
                      subtitle: Text('u/' + _posts.elementAt(index).author),
                      trailing: Icon(Icons.arrow_forward),
                      onTap: () async {
                        Navigator.pushNamed(context, '/subreddit',
                            arguments: {
                              'subreddit': _posts.elementAt(index).subReddit
                            });
                        print(_posts.elementAt(index));
                      },
                    ),
                    if (_posts.elementAt(index).is_video)
                      VideoWidget(
                          url: _posts
                              .elementAt(index)
                              .media!
                              .reddit_video_url!,
                          play: true),
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
                    ListTile(
                      title: Row(
                        children: [
                          const FaIcon(FontAwesomeIcons.commentAlt),
                          const Padding(
                            padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
                          ),
                          Text(prettyNumber(
                              _posts.elementAt(index).num_comments)),
                          const Padding(
                            padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
                          ),
                          const FaIcon(FontAwesomeIcons.arrowAltCircleUp),
                          const Padding(
                            padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
                          ),
                          Text(prettyNumber(_posts.elementAt(index).ups)),
                          const Padding(
                            padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
                          ),
                          const FaIcon(FontAwesomeIcons.arrowAltCircleDown),
                          const Padding(
                            padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
                          ),
                          Text(prettyNumber(_posts.elementAt(index).downs)),
                        ],
                      ),
                    ),
                    // ListTile(
                    //   trailing: (_posts.elementAt(index).preview == null)
                    //       ? SizedBox.shrink()
                    //       : Image.network(''),
                    //   title: Text(_posts.elementAt(index).title),
                    // ),
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

class VideoWidget extends StatefulWidget {
  final bool play;
  final String url;

  const VideoWidget({Key? key, required this.url, required this.play})
      : super(key: key);

  @override
  _VideoWidgetState createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  late VideoPlayerController videoPlayerController;
  late ChewieAudioController chewieAudioPlayerController;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    videoPlayerController = VideoPlayerController.network(widget.url);

    _initializeVideoPlayerFuture = videoPlayerController.initialize().then((_) {
      //       Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.

      chewieAudioPlayerController = ChewieAudioController(
          videoPlayerController: videoPlayerController,
          autoPlay: true,
          looping: false);
      setState(() {});
    });
  } // This closing tag was missing

  @override
  void dispose() {
    videoPlayerController.dispose();
    chewieAudioPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Card(
            key: PageStorageKey(widget.url),
            elevation: 5.0,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Chewie(
                    key: PageStorageKey(widget.url),
                    controller: ChewieController(
                      videoPlayerController: videoPlayerController,
                      aspectRatio: 3 / 2,
                      // Prepare the video to be played and display the first frame
                      autoInitialize: true,
                      looping: false,
                      autoPlay: false,
                      // Errors can occur for example when trying to play a video
                      // from a non-existent URL
                      errorBuilder: (context, errorMessage) {
                        return Center(
                          child: Text(
                            errorMessage,
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
