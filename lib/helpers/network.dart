import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:redditech/helpers/parser.dart';
import 'package:redditech/helpers/utils.dart';
import 'package:http/http.dart' as http;
import 'package:redditech/model/all_awardings.dart';
import 'package:redditech/model/posts.dart';
import 'package:redditech/model/preview.dart';
import 'package:redditech/model/subreddit.dart';
import 'package:redditech/model/subreddit_search.dart';
import 'package:redditech/model/trophies.dart';
import 'package:redditech/model/user.dart';

class NetworkHelper {
  static final NetworkHelper _instance = NetworkHelper._internal();
  static const _clientID = 'fgEGy01xVvt_6kcaMDiI3w';
  static const _redirectURI = 'me.app.local';
  static const _callbackScheme = "://login";

  factory NetworkHelper() {
    return _instance;
  }

  NetworkHelper._internal();

  Future<String?> _getAccessToken() async {
    const storage = FlutterSecureStorage();
    return await storage.read(key: 'access_token');
  }

  Future<void> _writeAccessToken(accessToken) async {
    const storage = FlutterSecureStorage();
    return await storage.write(key: 'access_token', value: accessToken);
  }

  Future<bool> loginImplicitGrantFlow() async {
    final _randomString = getRandomString(40);
    final authorizeUrl =
        Uri.https('www.reddit.com', '/api/v1/authorize.compact', {
      'client_id': _clientID,
      'response_type': 'token',
      'state': _randomString,
      'redirect_uri': _redirectURI + _callbackScheme,
      'scope': 'identity read',
    });
    try {
      final _authenticateResult = await FlutterWebAuth.authenticate(
        url: authorizeUrl.toString(),
        callbackUrlScheme: _redirectURI,
        preferEphemeral: true,
      );
      final _redditRawResponse = Uri.parse(_authenticateResult).fragment;
      final _queryResult = parseRedditAuthorizationResponse(_redditRawResponse);

      //TODO: Handle other errors (client_id invalid, redirect_uri invalid)
      // If the user pressed the refuse button
      if (_queryResult['error'] == 'access_denied') {
        throw ExceptionLoginUserRefused();
      }
      // if the state isn't equal to the random string we sent, then warn the user
      if (_queryResult['state'] != _randomString) {
        throw ExceptionLoginRandomString();
      }
      await _writeAccessToken(_queryResult['access_token']);
      return true;
    } on PlatformException catch (_) {
      throw (Exception("Aborted by user"));
    } on ExceptionLoginUserRefused catch (_) {
      throw (Exception("You refused the authentication. Please try again."));
    } on ExceptionLoginRandomString catch (_) {
      throw (Exception("Response from Reddit altered. Please try again."));
    } catch (e) {
      //TODO: Handle multi lines in order to display the error message to the end user.
    }
    return false;
  }

  Future<bool> loginExplicitGrantFlow() async {
    final _randomString = getRandomString(40);
    final authorizeUrl =
        Uri.https('www.reddit.com', '/api/v1/authorize.compact', {
      'client_id': _clientID,
      'response_type': 'code',
      'state': _randomString,
      'redirect_uri': _redirectURI + _callbackScheme,
      'scope': 'identity read',
    });
    try {
      final _authenticateResult = await FlutterWebAuth.authenticate(
        url: authorizeUrl.toString(),
        callbackUrlScheme: _redirectURI,
        preferEphemeral: true,
      );
      final _redditRawResponse = Uri.parse(_authenticateResult).query;
      final _queryResult = parseRedditAuthorizationResponse(_redditRawResponse);
      //TODO: Handle other errors (client_id invalid, redirect_uri invalid)
      // If the user pressed the refuse button
      if (_queryResult['error'] == 'access_denied') {
        throw ExceptionLoginUserRefused();
      }
      // if the state isn't equal to the random string we sent, then warn the user
      if (_queryResult['state'] != _randomString) {
        throw ExceptionLoginRandomString();
      }

      var response = await http.post(
        Uri.parse('https://www.reddit.com/api/v1/access_token'),
        headers: {
          'Authorization':
              'Basic ' + base64Encode(utf8.encode(_clientID + ':')),
          'User-Agent':
              'android:eu.epitech.redditech.redditech:v0.0.1 (by /u/M0nkeyPyth0n)',
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: {
          'grant_type': 'authorization_code',
          'code': _queryResult['code'],
          'redirect_uri': _redirectURI + _callbackScheme,
        },
        encoding: Encoding.getByName("utf-8"),
      );
      final _accessResponse = jsonDecode(response.body);
      await _writeAccessToken(_accessResponse['access_token']);
      return true;
    } on PlatformException catch (_) {
      throw (Exception("Aborted by user"));
    } on ExceptionLoginUserRefused catch (_) {
      throw (Exception("You refused the authentication. Please try again."));
    } on ExceptionLoginRandomString catch (_) {
      throw (Exception("Response from Reddit altered. Please try again."));
    } catch (e) {
      //TODO: Handle multi lines in order to display the error message to the end user.
    }
    return false;
  }

  Future<List<Trophies>> fetchUserTrophies() async {
    String _token = (await _getAccessToken())!;
    var response = await http.get(
        Uri.parse('https://oauth.reddit.com/api/v1/me/trophies?raw_json=1'),
        headers: {
          'authorization': 'bearer ' + _token,
          'User-Agent':
              'android:eu.epitech.redditech.redditech:v0.0.1 (by /u/M0nkeyPyth0n)',
        });
    if (response.statusCode == 401) {
      throw ExceptionLoginInvalid();
    }
    List<Trophies> _trophies = [];
    Map<String, dynamic> resp = jsonDecode(response.body);
    List<dynamic> toto = resp['data']['trophies'];
    for (var element in toto) {
      Trophies _trophy = Trophies(
          name: element['data']['name'] ?? '',
          description: element['data']['description'] ?? 'No description',
          icon_70_url: element['data']['icon_70'] ?? 'No description',
          granted_at: element['data']['granted_at'] ?? 99999999,
          icon_40_url: element['data']['icon_40'] ?? 99999999);
      _trophies.add(_trophy);
    }
    return _trophies;
  }

  Future<User> fetchUserData() async {
    String _token = (await _getAccessToken())!;
    var response = await http.get(
        Uri.parse('https://oauth.reddit.com/api/v1/me?raw_json=1'),
        headers: {
          'authorization': 'bearer ' + _token,
          'User-Agent':
              'android:eu.epitech.redditech.redditech:v0.0.1 (by /u/M0nkeyPyth0n)',
        });
    if (response.statusCode == 401) {
      throw ExceptionLoginInvalid();
    }
    Map<String, dynamic> resp = jsonDecode(response.body);

    User user = User(
        name: resp['name'],
        namePrefixed: resp['subreddit']['display_name_prefixed'],
        description: resp['subreddit']['public_description'],
        banner:
            (resp['subreddit']['banner_img'] as String).isEmpty ? false : true,
        bannerURL: resp['subreddit']['banner_img'],
        iconURL: resp['icon_img'],
        totalKarma: resp['total_karma'],
        created: resp['created_utc']);
    return user;
  }

  Future<String> getSubRedditIcon(String subRedditName) async {
    var response = await http.get(
      Uri.parse(
          'https://www.reddit.com/r/$subRedditName/about.json?raw_json=1'),
      headers: {
        'User-Agent':
            'android:eu.epitech.redditech.redditech:v0.0.1 (by /u/M0nkeyPyth0n)',
      },
    );
    Map<String, dynamic> resp = jsonDecode(response.body);
    if (resp['data']['community_icon'] != '') {
      return resp['data']['community_icon'];
    }
    if (resp['data']['icon_img'] != '') {
      return resp['data']['icon_img'];
    }
    return '';
  }

  Future<List<SubRedditSearch>> fetchSubreddits(String query) async {
    List<SubRedditSearch> _subreddits = [];
    String _token = (await _getAccessToken())!;
    var response = await http.post(
      Uri.parse('https://oauth.reddit.com/api/search_subreddits'),
      headers: {
        'authorization': 'bearer ' + _token,
        'User-Agent':
            'android:eu.epitech.redditech.redditech:v0.0.1 (by /u/M0nkeyPyth0n)',
      },
      body: {
        'exact': 'false',
        'include_over_18': 'false',
        'include_unadvertisable': 'false',
        'query': query,
      },
    );
    if (response.statusCode == 401) {
      throw ExceptionLoginInvalid();
    }
    Map<String, dynamic> resp = jsonDecode(response.body);

    for (var element in resp['subreddits']) {
      String _iconImg = await getSubRedditIcon(element['name']);
      SubRedditSearch _subreddit = SubRedditSearch(
          active_user_count: element['active_user_count'],
          icon_img: _iconImg,
          name: element['name'],
          subscriber_count: element['subscriber_count']);
      _subreddits.add(_subreddit);
    }
    return _subreddits;
  }

  Future<SubReddit> fetchSubredditData(subreddit_name) async {
    var response = await http.get(
        Uri.parse(
            'https://www.reddit.com/r/$subreddit_name/about.json?raw_json=1'),
        headers: {
          'User-Agent':
              'android:eu.epitech.redditech.redditech:v0.0.1 (by /u/M0nkeyPyth0n)',
        });
    if (response.statusCode == 401) {
      throw ExceptionLoginInvalid();
    }
    Map<String, dynamic> resp = jsonDecode(response.body);
    SubReddit _subreddit = SubReddit(
      title: resp['data']['title'],
      subscribers: resp['data']['subscribers'],
      icon_img: (resp['data']['icon_img'] == '') ? null : resp['data']['icon_img'],
      display_name_prefixed: resp['data']['display_name_prefixed'],
      community_icon_url: (resp['data']['community_icon'] == '') ? null : resp['data']['community_icon'],
      banner_background_image_url: resp['data']['banner_background_image'],
      description_html: resp['data']['description_html'],
      created: resp['data']['created'],
      banner_background_color: resp['data']['banner_background_color'],
      mobile_banner_image: resp['data']['mobile_banner_image'],
      public_description: resp['data']['public_description'],
    );
    return _subreddit;
  }

  Future<List<Posts>> fetchUserPosts(String endpoint) async {
    String _token = (await _getAccessToken())!;
    var response = await http.get(
        Uri.parse('https://oauth.reddit.com/$endpoint?raw_json=1&limit=5'),
        headers: {
          'authorization': 'bearer ' + _token,
          'User-Agent':
              'android:eu.epitech.redditech.redditech:v0.0.1 (by /u/M0nkeyPyth0n)',
        });
    if (response.statusCode == 401) {
      throw ExceptionLoginInvalid();
    }
    Map<String, dynamic> resp = jsonDecode(response.body);
    // TODO: static which keeps resp['data']['after'] for pagination

    List<Posts> _posts = [];
    List<dynamic> toto = resp['data']['children'];
    for (var element in toto) {
      SubReddit _subreddit =
          await fetchSubredditData(element['data']['subreddit']);
      // TODO: Check if we can GET the image of if we get a 403 Varnish Cache error
      Posts _post = Posts(
        subreddit: element['data']['subreddit'],
        selftext: element['data']['selftext'],
        author_fullname: element['data']['author_fullname'],
        title: element['data']['title'],
        subreddit_name_prefixed: element['data']['subreddit_name_prefixed'],
        downs: element['data']['downs'],
        thumbnail_height: (element['data']['thumbnail_height'] == null)
            ? 0
            : element['data']['thumbnail_height'],
        name: element['data']['name'],
        upvote_ratio: element['data']['upvote_ratio'],
        ups: element['data']['ups'],
        total_awards_received: element['data']['total_awards_received'],
        thumbnail_width: (element['data']['thumbnail_width'] == null)
            ? 0
            : element['data']['thumbnail_width'],
        score: element['data']['score'],
        thumbnail: element['data']['thumbnail'],
        post_hint:
            ((element['data'] as Map<String, dynamic>).containsKey('post_hint'))
                ? element['data']['post_hint']
                : null,
        is_self: element['data']['is_self'],
        created: element['data']['created'],
        selftext_html: element['data']['selftext_html'],
        preview: parsePreview(element['data']),
        all_awardings: parseAllAwardings(element['data']['all_awardings']),
        subreddit_id: element['data']['subreddit_id'],
        id: element['data']['id'],
        author: element['data']['author'],
        num_comments: element['data']['num_comments'],
        permalink: element['data']['permalink'],
        url: element['data']['url'],
        subreddit_subscribers: element['data']['subreddit_subscribers'],
        media: parseMedia(element['data']),
        is_video: element['data']['is_video'],
        subReddit: _subreddit,
      );
      _posts.add(_post);
    }
    return _posts;
  }
}
