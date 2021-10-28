import 'package:flutter/material.dart';
import 'package:no_internet_check/internet_connectivity/initialize_internet_checker.dart';
import 'package:no_internet_check/internet_connectivity/navigation_Service.dart';
import 'package:redditech/screens/loading_view.dart';
import "package:redditech/screens/main_view.dart";
import 'package:redditech/screens/reddit_login_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  InternetChecker();
  runApp(MaterialApp(
    navigatorKey: NavigationService.navigationKey,
    debugShowCheckedModeBanner: true,
    initialRoute: '/',
    routes: {
      '/': (context) => const LoadingView(),
      '/login': (context) => const RedditLoginView(),
      '/main': (context) => const MainView(),
    },
  ));
}