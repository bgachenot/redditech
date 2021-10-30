class SubRedditSearch {
  final int active_user_count;
  final String? icon_img;
  final String? community_icon;
  final String name;
  final int subscriber_count;

  SubRedditSearch({
    required this.active_user_count,
    required this.icon_img,
    required this.community_icon,
    required this.name,
    required this.subscriber_count,
  });

  Map<String, dynamic> toJson() {
    return {
      'active_user_count': active_user_count,
      'icon_img': icon_img,
      'community_icon': community_icon,
      'name': name,
      'subscriber_count': subscriber_count,
    };
  }

  SubRedditSearch.fromJson(Map<String, dynamic> res)
      : active_user_count = res['active_user_count'],
        icon_img = res['icon_img'],
        community_icon = res['community_icon'],
        name = res['name'],
        subscriber_count = res['subscriber_count'];

  @override
  String toString() {
    return 'SubRedditSearch{active_user_count: $active_user_count, icon_img: $icon_img, community_icon: $community_icon, name: $name, subscriber_count: $subscriber_count}';
  }
}
