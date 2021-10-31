import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:redditech/helpers/utils.dart';
import 'package:redditech/model/posts.dart';
import 'package:redditech/widgets/video_widget.dart';

class DisplayPost extends StatefulWidget {
  const DisplayPost({Key? key}) : super(key: key);

  @override
  _DisplayPostState createState() => _DisplayPostState();
}

class _DisplayPostState extends State<DisplayPost> {
  late Posts _post;
  Map _data = {};

  @override
  Widget build(BuildContext context) {
    _data = _data.isNotEmpty
        ? _data
        : ModalRoute.of(context)!.settings.arguments as Map;
    _post = _data['post'];
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: <Widget>[
          ListTile(
            leading: Image.network(_post
                .subReddit
                .community_icon ??
                _post.subReddit.icon_img!),
            title: Text(_post
                .subReddit
                .display_name_prefixed),
            subtitle: Text('u/' + _post.author),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () async {
              Navigator.pushNamed(context, '/subreddit', arguments: {
                'subreddit': _post.subReddit
              });
            },
          ),
          if (_post.all_awardings != null)
            ListTile(
              tileColor: Colors.grey[300],
              leading: const Text('Show rewards'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {},
            ),
          if (_post.is_video &&
              _post.media!.reddit_video)
            VideoWidget(
              url: _post.media!.reddit_video_url!,
              play: true,
            ),
          if (_post.post_hint != null &&
              _post.post_hint == 'image')
            Column(
              children: [
                ListTile(
                  title: Text(_post.title),
                  subtitle: Image.network(
                      _post.preview!.source_url),
                ),
              ],
            ),
          ListTile(
            title: Row(
              children: [
                const FaIcon(FontAwesomeIcons.commentAlt),
                const Padding(
                    padding: EdgeInsets.fromLTRB(8, 0, 0, 0)),
                Text(prettyNumber(
                    _post.num_comments)),
                const Padding(
                    padding: EdgeInsets.fromLTRB(8, 0, 0, 0)),
                const FaIcon(FontAwesomeIcons.arrowAltCircleUp),
                const Padding(
                    padding: EdgeInsets.fromLTRB(8, 0, 0, 0)),
                Text(prettyNumber(_post.ups)),
                const Padding(
                    padding: EdgeInsets.fromLTRB(8, 0, 0, 0)),
                const FaIcon(FontAwesomeIcons.arrowAltCircleDown),
                const Padding(
                    padding: EdgeInsets.fromLTRB(8, 0, 0, 0)),
                Text(prettyNumber(_post.downs)),
              ],
            ),
          ),
          // ListTile(
          //   trailing: (_post.preview == null)
          //       ? SizedBox.shrink()
          //       : Image.network(''),
          //   title: Text(_post.title),
          // ),
        ],
      ),
    );
  }
}
