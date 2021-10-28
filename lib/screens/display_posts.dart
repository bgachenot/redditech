import 'package:flutter/material.dart';
import 'package:redditech/helpers/network.dart';
import 'package:redditech/helpers/utils.dart';
import 'package:redditech/model/posts.dart';
import 'package:redditech/widgets/loading_data.dart';

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
      Navigator.pushReplacementNamed(context, '/login', arguments: {'error': 'Authentication expired.'});
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
                Card(
                  child: InkWell(
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/subreddit', arguments: {'subreddit': _posts.elementAt(index).subReddit});
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
                          subtitle:
                          Text('u/' + _posts.elementAt(index).author),
                          trailing: Icon(Icons.arrow_forward),
                          onTap: () async {
                            Navigator.pushNamed(context, '/subreddit',
                                arguments: {'subreddit': _posts.elementAt(index).subReddit});
                            print(_posts.elementAt(index));
                          },
                        ),
                        ListTile(
                          trailing: (_posts.elementAt(index).preview == null)
                              ? SizedBox.shrink()
                              : Image.network(
                              _posts.elementAt(index).preview!),
                          title: Text(_posts.elementAt(index).title),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            const Icon(
                              IconData(58353, fontFamily: 'MaterialIcons'),
                            ),
                            Text(
                              _posts.elementAt(index).num_comments.toString(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          });
    }
  }
}
