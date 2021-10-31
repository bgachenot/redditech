class SubRedditSearch {
  final String display_name;
  final String? icon_img;
  final String display_name_prefixed;
  final int subscribers;
  String name;
  final String? public_description;
  final String? community_icon;
  final String id;

  SubRedditSearch({
    required this.display_name,
    required this.icon_img,
    required this.display_name_prefixed,
    required this.subscribers,
    required this.name,
    required this.public_description,
    required this.community_icon,
    required this.id,
  });
}
