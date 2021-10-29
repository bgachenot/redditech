import 'dart:convert';

import 'package:redditech/model/all_awardings.dart';
import 'package:redditech/model/media.dart';
import 'package:redditech/model/preview.dart';

Map<String, dynamic> parseRedditAuthorizationResponse(
    String _redditRawResponse) {
  final _redditSplitRawResponse = _redditRawResponse.split('&');
  var _redditRawJsonResponse = "{";
  for (int i = 0; i != _redditSplitRawResponse.length; i++) {
    var key = _redditSplitRawResponse[i].split('=')[0];
    var value = _redditSplitRawResponse[i].split('=')[1];

    _redditRawJsonResponse += '"$key": "$value"' +
        (i + 1 == _redditSplitRawResponse.length ? '}' : ',');
  }
  return jsonDecode(_redditRawJsonResponse);
}

List<AllAwardings>? parseAllAwardings(jsonData) {
  return null;
}

Preview? parsePreview(Map<String, dynamic> jsonData) {
  if (jsonData.containsKey('preview')) {
    return Preview(
        enabled: jsonData['preview']['enabled'],
        source_url: jsonData['preview']['images'][0]['source']['url'],
        source_width: jsonData['preview']['images'][0]['source']['width'],
        source_height: jsonData['preview']['images'][0]['source']['height']);
  } else {
    return null;
  }
}

Media? parseMedia(Map<String, dynamic> jsonData) {
  if (jsonData['media'] == null) {
    return null;
  } else {
    if ((jsonData['media'] as Map<String, dynamic>)
        .containsKey('reddit_video')) {
      return Media(
        reddit_video: true,
        youtube_video: false,
        reddit_gif: false,
        reddit_video_url: jsonData['media']['reddit_video']['fallback_url'],
        reddit_video_height: jsonData['media']['reddit_video']['height'],
        reddit_video_width: jsonData['media']['reddit_video']['width'],
        reddit_video_duration: jsonData['media']['reddit_video']['duration'],
      );
    }
    return null;
  }
}
