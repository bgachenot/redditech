import 'package:flutter/material.dart';
import 'package:redditech/screens/display_posts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FeedView extends StatefulWidget {
  const FeedView({Key? key}) : super(key: key);

  @override
  _FeedViewState createState() => _FeedViewState();
}

class _FeedViewState extends State<FeedView>
    with SingleTickerProviderStateMixin {
  final String _appBarTitle = "Top posts for you";
  static const List<Tab> _myTabs = <Tab>[
    Tab(
      child: Text(
        'Best',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
    ),
    Tab(
      child: Text(
        'Top',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
    ),
    Tab(
      child: Text(
        'New',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
    ),
    Tab(
      child: Text(
        'Random',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
    ),
  ];
  static const List<String> _myEndpoints = [
    "best",
    "top",
    "new",
    "random",
  ];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: _myTabs.length);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitle),
        centerTitle: true,
        bottom: TabBar(
          onTap: (index) {
            setState(() {
              _tabController.index = index;
            });
          },
          controller: _tabController,
          tabs: _myTabs,
        ),
      ),
      body: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _tabController,
        children: _myTabs.map((Tab tab) {
          return DisplayPosts(endpoint: _myEndpoints[_tabController.index]);
        }).toList(),
      ),
    );
  }
}
