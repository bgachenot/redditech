import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:redditech/helpers/parser.dart';
import 'package:redditech/helpers/utils.dart';
import 'package:http/http.dart' as http;
import 'package:redditech/model/posts.dart';
import 'package:redditech/model/preferences.dart';
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
    await storage.write(key: 'access_token', value: accessToken);
  }

   Future<void> _deleteAllSecureStorage() async {
    const storage = FlutterSecureStorage();
    await storage.deleteAll();
  }

  Future<bool> disconnectUser() async {
    String? _token = await _getAccessToken();

    await _deleteAllSecureStorage();
    return true;
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
      'scope': 'identity read mysubreddits subscribe account',
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

  Future<bool> patchUserPrefs(String keyName, dynamic keyValue) async {
    String _token = (await _getAccessToken())!;
    String _body = '{"$keyName": "$keyValue"}';
    var response = await http.patch(
      Uri.parse('https://oauth.reddit.com/api/v1/me/prefs'),
      headers: {
        'authorization': 'bearer ' + _token,
        'User-Agent':
            'android:eu.epitech.redditech.redditech:v0.0.1 (by /u/M0nkeyPyth0n)',
        'Content-Type': 'text/plain',
      },
      body: _body,
    );
    if (response.statusCode == 401) {
      throw ExceptionLoginInvalid();
    }
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  Future<UserPreferencies> fetchUserPrefs() async {
    String _token = (await _getAccessToken())!;
    var response = await http
        .get(Uri.parse('https://oauth.reddit.com/api/v1/me/prefs'), headers: {
      'authorization': 'bearer ' + _token,
      'User-Agent':
          'android:eu.epitech.redditech.redditech:v0.0.1 (by /u/M0nkeyPyth0n)',
    });
    if (response.statusCode == 401) {
      throw ExceptionLoginInvalid();
    }
    Map<String, dynamic> resp = jsonDecode(response.body);
    UserPreferencies _userPreferencies = UserPreferencies(
      accept_pms: resp['accept_pms'],
      hide_from_robots: resp['hide_from_robots'],
      allow_clicktracking: resp['allow_clicktracking'],
      third_party_data_personalized_ads:
          resp['third_party_data_personalized_ads'],
      third_party_site_data_personalized_ads:
          resp['third_party_site_data_personalized_ads'],
      show_location_based_recommendations:
          resp['show_location_based_recommendations'],
      third_party_site_data_personalized_content:
          resp['third_party_site_data_personalized_content'],
      enable_followers: resp['enable_followers'],
    );
    return _userPreferencies;
  }

  Future<bool> subRedditSubscription(
      String subredditThingName, bool sub) async {
    String _token = (await _getAccessToken())!;
    var response = await http.post(
      Uri.parse('https://oauth.reddit.com/api/subscribe'),
      headers: {
        'Authorization': 'Bearer ' + _token,
        "Content-Type": "application/x-www-form-urlencoded",
        'User-Agent':
            'android:eu.epitech.redditech.redditech:v0.0.1 (by /u/M0nkeyPyth0n)',
      },
      body: {
        'action': sub ? 'sub' : 'unsub',
        'sr': subredditThingName,
      },
    );
    if (response.statusCode == 401) {
      throw ExceptionLoginInvalid();
    }
    if (response.statusCode == 200) {
      return sub;
    } else if (response.statusCode == 404 && sub == false) {
      return sub;
    } else {
      return !sub;
    }
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

  Future<List<SubRedditSearch>> searchSubreddits(String query) async {
    List<SubRedditSearch> _subreddits = [];
    String _token = (await _getAccessToken())!;
    var response = await http.get(
      Uri.parse(
          'https://oauth.reddit.com/search?q=$query&type=sr&restrict_sr=true&raw_json=1'),
      headers: {
        'authorization': 'bearer ' + _token,
        'User-Agent':
        'android:eu.epitech.redditech.redditech:v0.0.1 (by /u/M0nkeyPyth0n)',
      },
    );
    if (response.statusCode == 401) {
      throw ExceptionLoginInvalid();
    }
    Map<String, dynamic> resp = jsonDecode(response.body);

    if (resp.containsKey('data') &&
        (resp['data'] as Map<String, dynamic>).containsKey('children')) {
      for (var element in resp['data']['children']) {
        SubRedditSearch _subreddit = SubRedditSearch(
            display_name: element['data']['display_name'],
            icon_img: parseredditStrings(element['data']['icon_img']),
            display_name_prefixed: element['data']['display_name_prefixed'],
            subscribers: element['data']['subscribers'] ?? 0,
            name: element['data']['name'],
            public_description: parseredditStrings(element['data']['public_description']),
            community_icon:
            parseredditStrings(element['data']['community_icon']),
            id: element['data']['id']);
        _subreddits.add(_subreddit);
      }
      _subreddits.elementAt(_subreddits.length - 1).name = resp['data']['after'];
    }
    return _subreddits;
  }
  Future<List<SubRedditSearch>> searchMoreSubreddits(String query, String lastFullName) async {
    List<SubRedditSearch> _subreddits = [];
    String _token = (await _getAccessToken())!;
    var response = await http.get(
      Uri.parse(
          'https://oauth.reddit.com/search?q=$query&type=sr&restrict_sr=true&raw_json=1&after=$lastFullName'),
      headers: {
        'authorization': 'bearer ' + _token,
        'User-Agent':
        'android:eu.epitech.redditech.redditech:v0.0.1 (by /u/M0nkeyPyth0n)',
      },
    );
    if (response.statusCode == 401) {
      throw ExceptionLoginInvalid();
    }
    Map<String, dynamic> resp = jsonDecode(response.body);

    if (resp.containsKey('data') &&
        (resp['data'] as Map<String, dynamic>).containsKey('children')) {
      for (var element in resp['data']['children']) {
        SubRedditSearch _subreddit = SubRedditSearch(
            display_name: element['data']['display_name'],
            icon_img: parseredditStrings(element['data']['icon_img']),
            display_name_prefixed: element['data']['display_name_prefixed'],
            subscribers: element['data']['subscribers'] ?? 0,
            name: element['data']['name'],
            public_description: parseredditStrings(element['data']['public_description']),
            community_icon:
            parseredditStrings(element['data']['community_icon']),
            id: element['data']['id']);
        _subreddits.add(_subreddit);
      }
      _subreddits.elementAt(_subreddits.length - 1).name = resp['data']['after'];
    }
    return _subreddits;
  }

  Future<SubReddit> fetchSubredditData(subredditName) async {
    String _token = (await _getAccessToken())!;
    var response = await http.get(
        Uri.parse('https://oauth.reddit.com/r/$subredditName/about?raw_json=1'),
        headers: {
          'authorization': 'bearer ' + _token,
          'User-Agent':
              'android:eu.epitech.redditech.redditech:v0.0.1 (by /u/M0nkeyPyth0n)',
        });
    if (response.statusCode == 401) {
      throw ExceptionLoginInvalid();
    }
    Map<String, dynamic> resp = jsonDecode(response.body);
    SubReddit _subreddit = SubReddit(
      display_name: resp['data']['display_name'],
      title: resp['data']['title'],
      active_user_count: resp['data']['active_user_count'],
      icon_img: parseredditStrings(resp['data']['icon_img']),
      display_name_prefixed: resp['data']['display_name_prefixed'],
      accounts_active: resp['data']['accounts_active'],
      subscribers: resp['data']['subscribers'],
      name: resp['data']['name'],
      public_description: resp['data']['public_description'],
      user_has_favorited: resp['data']['user_has_favorited'],
      community_icon: parseredditStrings(resp['data']['community_icon']),
      banner_background_image:
          parseredditStrings(resp['data']['banner_background_image']),
      description_html: resp['data']['description_html'],
      created: resp['data']['created'],
      user_is_subscriber: resp['data']['user_is_subscriber'],
      public_description_html: resp['data']['public_description_html'],
      accept_followers: resp['data']['accept_followers'],
      banner_img: parseredditStrings(resp['data']['banner_img']),
      description: resp['data']['description'],
      url: resp['data']['url'],
      mobile_banner_image:
          parseredditStrings(resp['data']['mobile_banner_image']),
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

    List<Posts> _posts = [];
    List<dynamic> toto = resp['data']['children'];
    for (var element in toto) {
      SubReddit _subreddit =
          await fetchSubredditData(element['data']['subreddit']);
      Posts _post = Posts(
        subreddit: element['data']['subreddit'],
        selftext: element['data']['selftext'],
        author_fullname: element['data']['author_fullname'],
        title: element['data']['title'],
        subreddit_name_prefixed: element['data']['subreddit_name_prefixed'],
        downs: element['data']['downs'],
        thumbnail_height: parseredditInts(element['data']['thumbnail_height']),
        name: element['data']['name'],
        upvote_ratio: element['data']['upvote_ratio'],
        ups: element['data']['ups'],
        total_awards_received: element['data']['total_awards_received'],
        thumbnail_width: parseredditInts(element['data']['thumbnail_width']),
        score: element['data']['score'],
        thumbnail: element['data']['thumbnail'],
        post_hint: parseredditStrings(element['data']['post_hint']),
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
    _posts.elementAt(_posts.length - 1).name = resp['data']['after'];
    return _posts;
  }

  Future<List<Posts>> fetchMoreUserPosts(
      String endpoint, String lastFullName) async {
    String _token = (await _getAccessToken())!;
    var response = await http.get(
        Uri.parse(
            'https://oauth.reddit.com/$endpoint?raw_json=1&limit=5&after=$lastFullName'),
        headers: {
          'authorization': 'bearer ' + _token,
          'User-Agent':
              'android:eu.epitech.redditech.redditech:v0.0.1 (by /u/M0nkeyPyth0n)',
        });
    if (response.statusCode == 401) {
      throw ExceptionLoginInvalid();
    }
    Map<String, dynamic> resp = jsonDecode(response.body);

    List<Posts> _posts = [];
    List<dynamic> toto = resp['data']['children'];
    for (var element in toto) {
      SubReddit _subreddit =
          await fetchSubredditData(element['data']['subreddit']);
      Posts _post = Posts(
        subreddit: element['data']['subreddit'],
        selftext: element['data']['selftext'],
        author_fullname: element['data']['author_fullname'],
        title: element['data']['title'],
        subreddit_name_prefixed: element['data']['subreddit_name_prefixed'],
        downs: element['data']['downs'],
        thumbnail_height: parseredditInts(element['data']['thumbnail_height']),
        name: element['data']['name'],
        upvote_ratio: element['data']['upvote_ratio'],
        ups: element['data']['ups'],
        total_awards_received: element['data']['total_awards_received'],
        thumbnail_width: parseredditInts(element['data']['thumbnail_width']),
        score: element['data']['score'],
        thumbnail: element['data']['thumbnail'],
        post_hint: parseredditStrings(element['data']['post_hint']),
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
    _posts.elementAt(_posts.length - 1).name = resp['data']['after'];
    return _posts;
  }
}
