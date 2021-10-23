import 'package:flutter/material.dart';
import 'package:redditech/screens/loading_view.dart';
import "package:redditech/screens/main_view.dart";
import 'package:redditech/screens/reddit_login_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: true,
    initialRoute: '/',
    routes: {
      '/': (context) => const LoadingView(),
      '/login': (context) => const RedditLoginView(),
      '/main': (context) => const MainView(),
    },
  ));
}