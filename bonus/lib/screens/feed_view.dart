import 'package:flutter/material.dart';
import 'package:redditech/screens/display_posts.dart';

class FeedView extends StatefulWidget {
  const FeedView({Key? key}) : super(key: key);

  @override
  _FeedViewState createState() => _FeedViewState();
}

class _FeedViewState extends State<FeedView>
    with SingleTickerProviderStateMixin {
  static const List<Tab> _myTabs = <Tab>[
    Tab(
      child: Text(
        'Best',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    ),
    Tab(
      child: Text(
        'Top',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    ),
    Tab(
      child: Text(
        'New',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    ),
    Tab(
      child: Text(
        'Rising',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    ),
    Tab(
      child: Text(
        'Controversial',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    ),
  ];
  static const List<String> _myEndpoints = [
    "best",
    "top",
    "new",
    "rising",
    "controversial",
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
        title: Text(
            _myEndpoints[_tabController.index].substring(0, 1).toUpperCase() +
                _myEndpoints[_tabController.index].substring(1) +
                ' posts for you'),
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
        children: const [
          DisplayPosts(endpoint: 'best'),
          DisplayPosts(endpoint: 'top'),
          DisplayPosts(endpoint: 'new'),
          DisplayPosts(endpoint: 'rising'),
          DisplayPosts(endpoint: 'controversial'),
        ],
      ),
    );
  }
}
