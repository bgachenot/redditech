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

List<AllAwardings>? parseAllAwardings(List<dynamic> jsonData) {
  List<AllAwardings> _allAwardings = [];
  if (jsonData.isEmpty) {
    return null;
  } else {
    for (int i = 0; i != jsonData.length; i++) {
      AllAwardings _awarding = AllAwardings(
        coin_price: jsonData[i]['coin_price'],
        id: jsonData[i]['id'],
        coin_reward: jsonData[i]['coin_reward'],
        icon_url: jsonData[i]['icon_url'],
        icon_width: jsonData[i]['icon_width'],
        static_icon_width: jsonData[i]['static_icon_width'],
        description: jsonData[i]['description'],
        count: jsonData[i]['count'],
        name: jsonData[i]['name'],
        icon_format: jsonData[i]['icon_format'],
        icon_height: jsonData[i]['icon_height'],
        static_icon_url: jsonData[i]['static_icon_url'],
      );
      _allAwardings.add(_awarding);
    }
    return _allAwardings;
  }
}

Preview? parsePreview(Map<String, dynamic> jsonData) {
  if (jsonData.containsKey('preview')) {
    if ((jsonData['preview'] as Map<String, dynamic>)
        .containsKey('reddit_video_preview')) {
      return Preview(
          enabled: jsonData['preview']['enabled'],
          source_url: jsonData['preview']['images'][0]['source']['url'],
          source_width: jsonData['preview']['images'][0]['source']['width'],
          source_height: jsonData['preview']['images'][0]['source']['height'],
          reddit_video_preview: true,
          reddit_video_url: jsonData['preview']['reddit_video_preview']
              ['fallback_url']);
    } else {
      return Preview(
          enabled: jsonData['preview']['enabled'],
          source_url: jsonData['preview']['images'][0]['source']['url'],
          source_width: jsonData['preview']['images'][0]['source']['width'],
          source_height: jsonData['preview']['images'][0]['source']['height'],
          reddit_video_preview: false,
          reddit_video_url: null);
    }
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
    if ((jsonData['media'] as Map<String, dynamic>).containsKey('oembed') &&
        jsonData['type'] == 'redgifs.com') {
      return Media(
          reddit_video: false,
          youtube_video: false,
          reddit_gif: true,
          reddit_video_url: null,
          reddit_video_height: null,
          reddit_video_width: null,
          reddit_video_duration: null);
    }
    return null;
  }
}

String? parseredditStrings(String? str) {
  if (str == null || str == '') {
    return null;
  }
  return str;
}

int parseredditInts(int? number) {
  if (number == null) {
    return 0;
  }
  return number;
}
