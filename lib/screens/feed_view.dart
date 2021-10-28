import 'package:flutter/material.dart';
import 'package:redditech/screens/best_posts.dart';
import 'package:redditech/screens/new_posts.dart';
import 'package:redditech/screens/top_posts.dart';

class FeedView extends StatefulWidget {
  const FeedView({Key? key}) : super(key: key);

  @override
  _FeedViewState createState() => _FeedViewState();
}

class _FeedViewState extends State<FeedView> {
  bool _best = false;
  bool _top = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_best ? 'Best posts for you' : _top ? 'Top posts for you' : 'New posts for you'),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Theme.of(context).hintColor),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Card(
                  child: InkWell(
                    splashColor: Colors.blue.withAlpha(30),
                    onTap: () {
                      _best = true;
                      _top = false;
                      setState(() {});
                    },
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.30,
                      height: MediaQuery.of(context).size.width * 0.15,
                      child: const Text('Best'),
                    ),
                  ),
                ),
                Card(
                  child: InkWell(
                    splashColor: Colors.blue.withAlpha(30),
                    onTap: () {
                      _best = false;
                      _top = true;
                      setState(() {});
                    },
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.30,
                      height: MediaQuery.of(context).size.width * 0.15,
                      child: const Text('Top'),
                    ),
                  ),
                ),
                Card(
                  child: InkWell(
                    splashColor: Colors.blue.withAlpha(30),
                    onTap: () {
                      _best = false;
                      _top = false;
                      setState(() {});
                    },
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.30,
                      height: MediaQuery.of(context).size.width * 0.15,
                      child: const Text('New'),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height - 230,
            child: (_best) ? BestPostsView() : (_top) ? TopPostsView() : NewPostsView(),
          )
        ],
      ),
    );
  }
}
