import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:no_internet_check/internet_connectivity/initialize_internet_checker.dart';
import 'package:no_internet_check/internet_connectivity/navigation_Service.dart';
import 'package:redditech/screens/display_post.dart';
import 'package:redditech/screens/loading_view.dart';
import "package:redditech/screens/main_view.dart";
import 'package:redditech/screens/reddit_login_view.dart';
import 'package:redditech/screens/subreddit_view.dart';
import 'package:redditech/screens/trophies_view.dart';
import 'package:redditech/screens/user_settings.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  InternetChecker();
  // SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
  //   statusBarColor: Colors.transparent,
  // ));
  runApp(MaterialApp(
    navigatorKey: NavigationService.navigationKey,
    initialRoute: '/',
    debugShowCheckedModeBanner: false,
    theme: ThemeData.from(colorScheme: ColorScheme.light(background: Colors.grey.shade100)),
    routes: {
      '/': (context) => const LoadingView(),
      '/login': (context) => const RedditLoginView(),
      '/main': (context) => const MainView(),
      '/subreddit': (context) => const SubRedditView(),
      '/post': (context) => const DisplayPost(),
      '/trophies': (context) => const TrophiesView(),
      '/userSettings': (context) => const UserSettingsView(),
    },
  ));
}