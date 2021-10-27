import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:redditech/helpers/parser.dart';
import 'package:redditech/helpers/utils.dart';
import 'package:http/http.dart' as http;
import 'package:redditech/model/posts.dart';
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

  Future<bool> login() async {
    // https://www.reddit.com/api/v1/authorize?client_id=7sv_rACJq0_AD82DfuuUag&response_type=code&state=RANDOM_STRING&redirect_uri=https://google.com&scope=identity,read,account,creddits,edit,flair,history,livemanage,modconfig,modcontributors,modflair,modlog,modmail,modothers,modposts,modself,modwiki,mysubreddits,privatemessages,report,save,structuredstyles,submit,subscribe,vote,wikiedit,wikiread&duration=permanent
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
      print(_authenticateResult.toString());
      final _redditRawResponse = Uri
          .parse(_authenticateResult)
          .fragment;
      final _queryResult = parseRedditAuthorizationResponse(_redditRawResponse);
      print(_queryResult);

      //TODO: Handle other errors (client_id invalid, redirect_uri invalid)
      // If the user pressed the refuse button
      if (_queryResult['error'] == 'access_denied') {
        throw ExceptionLoginUserRefused();
      }
      // if the state isn't equal to the random string we sent, then warn the user
      if (_queryResult['state'] != _randomString) {
        throw ExceptionLoginRandomString();
      }

      //await _writeAccessToken(_queryResult['access_token']);
      //await _writeAccessToken("737496854301-1e8VGWOkhWKQIdyzIKH2JtvtE6gROw"); // moi
      await _writeAccessToken(
          "1675389028-xKniuGXth4bzYorx-HhE9TxMFyguCQ"); // Noe
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

  Future<List<Posts>> fetchUserBestPosts() async {
    String _token = (await _getAccessToken())!;
    var response = await http.get(
        Uri.parse('https://oauth.reddit.com/best?raw_json=1&limit=1'),
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
      Posts _post = Posts(title: element['data']['title'],
          created_at: element['data']['created'],
          author: element['data']['author'],
          author_fullname: element['data']['author_fullname'],
          permalink: element['data']['permalink'],
          thumbnail_url: element['data']['thumbnail'],
          thumbnail_height: element['data']['thumbnail_height'],
          thumbnail_width: element['data']['thumbnail_width'],
          ups: element['data']['ups'],
          allow_live_comments: element['data']['allow_live_comments'],
          locked: element['data']['locked'],
          subreddit_id: element['data']['subreddit_id'],
          id: element['data']['id'],
          num_comments: element['data']['num_comments']);
      _posts.add(_post);
    }
    return _posts;
  }
}
