import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:redditech/helpers/network.dart';
import 'package:redditech/helpers/utils.dart';
import 'package:redditech/model/subreddit.dart';
import 'package:redditech/screens/display_posts.dart';
import 'package:redditech/widgets/subreddit_banner.dart';
import 'package:redditech/widgets/subreddit_icon.dart';

class SubredditPostsView extends StatefulWidget {
  const SubredditPostsView({Key? key}) : super(key: key);

  @override
  _SubredditPostsViewState createState() => _SubredditPostsViewState();
}

class _SubredditPostsViewState extends State<SubredditPostsView>
    with SingleTickerProviderStateMixin {
  final bodyGlobalKey = GlobalKey();
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
  late TabController _tabController;
  late ScrollController _scrollController;
  late bool fixedScroll;
  final NetworkHelper _networkHelper = NetworkHelper();
  Map _data = {};
  late SubReddit _subreddit;

  Widget _displayIcons() {
    return Stack(
      children: [
        subredditBanner(_subreddit.mobile_banner_image, _subreddit.banner_img,
            _subreddit.banner_background_image),
        Padding(
            padding: const EdgeInsets.fromLTRB(20, 35, 0, 5),
            child:
                subredditIcon(_subreddit.community_icon, _subreddit.icon_img)),
      ],
    );
  }

  Widget _getAction() {
    if (_subreddit.user_is_subscriber == false) {
      return InkWell(
        onTap: () async {
          try {
            _subreddit.user_is_subscriber = await _networkHelper
                .subRedditSubscription(_subreddit.name, true);
          } on ExceptionLoginInvalid {
            Navigator.pushReplacementNamed(context, '/login',
                arguments: {'error': 'Authentication expired.'});
          }
          setState(() {});
        },
        child: Row(
          children: const [
            Icon(Icons.add),
            Text('follow', style: TextStyle(fontSize: 16)),
            Padding(padding: EdgeInsets.all(8)),
          ],
        ),
      );
    }
    return InkWell(
      onTap: () async {
        try {
          _subreddit.user_is_subscriber = await _networkHelper
              .subRedditSubscription(_subreddit.name, false);
        } on ExceptionLoginInvalid {
          Navigator.pushReplacementNamed(context, '/login',
              arguments: {'error': 'Authentication expired.'});
        }
        setState(() {});
      },
      child: Row(
        children: const [
          Icon(Icons.remove),
          Text('unfollow', style: TextStyle(fontSize: 16)),
          Padding(padding: EdgeInsets.all(8)),
        ],
      ),
    );
  }

  Widget _buildCarousel() {
    return Column(
      children: [
        _displayIcons(),
        Row(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Stack(
                children: [
                  SizedBox(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 15, 0, 0),
                      child: ExpandableText(
                        _subreddit.title,
                        expandText: 'show more',
                        collapseText: 'show less',
                        maxLines: 1,
                        linkColor: Colors.blue,
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                        MediaQuery.of(context).size.width - 135, 0, 0, 0),
                    child: ExpandableText(
                      _subreddit.subscribers.toString() + ' members',
                      expandText: 'show more',
                      collapseText: 'show less',
                      maxLines: 1,
                      linkColor: Colors.blue,
                      style: Theme.of(context).textTheme.subtitle2,
                    ),
                  ),
                  if (_subreddit.public_description != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 55, 0, 0),
                      child: ExpandableText(
                        _subreddit.public_description!,
                        collapseOnTextTap: true,
                        expandText: 'show more',
                        collapseText: 'show less',
                        maxLines: 2,
                        linkColor: Colors.blue,
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  void initState() {
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _tabController = TabController(length: _myTabs.length, vsync: this);
    _tabController.addListener(_smoothScrollToTop);

    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  _scrollListener() {
    if (fixedScroll) {
      _scrollController.jumpTo(0);
    }
  }

  _smoothScrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(microseconds: 300),
      curve: Curves.ease,
    );

    setState(() {
      fixedScroll = _tabController.index == 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    _data = _data.isNotEmpty
        ? _data
        : ModalRoute.of(context)!.settings.arguments as Map;
    _subreddit = _data['subreddit'];
    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, value) {
          return [
            SliverToBoxAdapter(child: _buildCarousel()),
            SliverToBoxAdapter(
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.redAccent,
                isScrollable: true,
                tabs: _myTabs,
              ),
            ),
          ];
        },
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _tabController,
          children: [
            DisplayPosts(endpoint: 'r/${_subreddit.display_name}/best'),
            DisplayPosts(endpoint: 'r/${_subreddit.display_name}/top'),
            DisplayPosts(endpoint: 'r/${_subreddit.display_name}/new'),
            DisplayPosts(endpoint: 'r/${_subreddit.display_name}/rising'),
            DisplayPosts(endpoint: 'r/${_subreddit.display_name}/controversial'),
          ],
        ),
      ),
    );
  }
}
