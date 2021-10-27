import 'package:redditech/model/subreddit.dart';

class Posts {
  final String title;
  final String selftext;
  final double created_at;
  final String author;
  final String author_fullname;
  final String permalink;
  final String? thumbnail_url;
  final int? thumbnail_height;
  final int? thumbnail_width;
  final String? preview;
  final int ups;
  final bool allow_live_comments;
  final bool locked;
  final String subreddit;
  final String subreddit_name_prefixed;
  final String subreddit_id;
  final String id;
  final int num_comments;
  final SubReddit subReddit;

  Posts({
    required this.title,
    required this.selftext,
    required this.created_at,
    required this.author,
    required this.author_fullname,
    required this.permalink,
    required this.thumbnail_url,
    required this.thumbnail_height,
    required this.thumbnail_width,
    required this.preview,
    required this.ups,
    required this.allow_live_comments,
    required this.locked,
    required this.subreddit,
    required this.subreddit_name_prefixed,
    required this.subreddit_id,
    required this.id,
    required this.num_comments,
    required this.subReddit,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'selftext': selftext,
      'created_at': created_at,
      'author': author,
      'author_fullname': author_fullname,
      'permalink': permalink,
      'thumbnail_url': thumbnail_url,
      'thumbnail_height': thumbnail_height,
      'thumbnail_width': thumbnail_width,
      'preview': preview,
      'ups': ups,
      'allow_live_comments': allow_live_comments,
      'locked': locked,
      'subreddit': subreddit,
      'subreddit_name_prefixed': subreddit_name_prefixed,
      'subreddit_id': subreddit_id,
      'id': id,
      'num_comments': num_comments,
    };
  }

  Posts.fromJson(Map<String, dynamic> res)
      : title = res['title'],
        selftext = res['selftext'],
        created_at = res['created_at'],
        author = res['author'],
        author_fullname = res['author_fullname'],
        permalink = res['permalink'],
        thumbnail_url = res['thumbnail_url'],
        thumbnail_height = res['thumbnail_height'],
        thumbnail_width = res['thumbnail_width'],
        preview = res['preview'],
        ups = res['ups'],
        allow_live_comments = res['allow_live_comments'],
        locked = res['locked'],
        subreddit = res['subreddit'],
        subreddit_name_prefixed = res['subreddit_name_prefixed'],
        subreddit_id = res['subreddit_id'],
        id = res['id'],
        num_comments = res['num_comments'],
        subReddit = res['subReddit'];

  @override
  String toString() {
    return 'Posts{title: $title, selftext: $selftext, created_at: $created_at, author: $author, author_fullname: $author_fullname, permalink: $permalink, thumbnail_url: $thumbnail_url, thumbnail_height: $thumbnail_height, thumbnail_width: $thumbnail_width, preview: $preview, ups: $ups, allow_live_comments: $allow_live_comments, locked: $locked, subreddit: $subreddit, subreddit_name_prefixed: $subreddit_name_prefixed, subreddit_id: $subreddit_id, id: $id, num_comments: $num_comments, subReddit, $subReddit';
  }
}
