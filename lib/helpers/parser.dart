import 'dart:convert';

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