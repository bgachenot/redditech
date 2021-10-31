import 'package:redditech/model/all_awardings.dart';
import 'package:redditech/model/media.dart';
import 'package:redditech/model/preview.dart';
import 'package:redditech/model/subreddit.dart';

class Posts {
  final String subreddit; // subreddit name
  final String selftext; // Can be ''
  final String author_fullname; // t2_ object
  final String title;
  final String subreddit_name_prefixed;
  final int downs;
  final int thumbnail_height; // can be null
  String name; // t3_ object (is used for next)
  final double upvote_ratio;
  final int ups;
  final int total_awards_received;
  final int thumbnail_width; // can be null
  final int score; // ups - down
  final String thumbnail; // 'self' or 'image' or 'https://<url>'
  final String? post_hint; //  'self' or 'link' or 'image' or 'hosted:video' (media will be fill by a reddit_video)
  final bool is_self; // idk ?
  final double created;
  final String? selftext_html; // Can be null
  final Preview? preview; // can be null
  final List<AllAwardings>? all_awardings; // can be null
  final String subreddit_id; // t5_ Object
  final String id;
  final String author;
  final int num_comments;
  final String permalink; // post permalink
  final String url; // url to comments
  final int subreddit_subscribers;
  final Media? media;
  final bool is_video; // If true, media is filled
  final SubReddit subReddit;

  Posts({
    required this.subreddit,
    required this.selftext,
    required this.author_fullname,
    required this.title,
    required this.subreddit_name_prefixed,
    required this.downs,
    required this.thumbnail_height,
    required this.name,
    required this.upvote_ratio,
    required this.ups,
    required this.total_awards_received,
    required this.thumbnail_width,
    required this.score,
    required this.thumbnail,
    required this.post_hint,
    required this.is_self,
    required this.created,
    required this.selftext_html,
    required this.preview,
    required this.all_awardings,
    required this.subreddit_id,
    required this.id,
    required this.author,
    required this.num_comments,
    required this.permalink,
    required this.url,
    required this.subreddit_subscribers,
    required this.media,
    required this.is_video,
    required this.subReddit,
  });
}