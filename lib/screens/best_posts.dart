import 'package:flutter/material.dart';
import 'package:redditech/helpers/network.dart';
import 'package:redditech/model/posts.dart';
import 'package:redditech/widgets/loading_data.dart';

class BestPostsView extends StatefulWidget {
  const BestPostsView({Key? key}) : super(key: key);

  @override
  _BestPostsViewState createState() => _BestPostsViewState();
}

class _BestPostsViewState extends State<BestPostsView> {
  final NetworkHelper _networkHelper = NetworkHelper();
  bool _initFinished = false;
  List<Posts> _posts = [];

  Future<void> initPosts() async {
    _posts = await _networkHelper.fetchUserBestPosts();
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
                thickness: 2.5,
              ),
          itemBuilder: (context, index) {
            return RefreshIndicator(
              onRefresh: () {
                return initPosts();
              },
              child: Column(
                children: [
                  Card(
                    child: InkWell(
                      onTap: () {
                        print(_posts.elementAt(index).num_comments);
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
                            onTap: () {},
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
              ),
            );
          });
    }
  }
}
