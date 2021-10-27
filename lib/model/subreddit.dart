class SubReddit {
  final String title;
  final int subscribers;
  final String icon_img;
  final String display_name_prefixed;
  final String? community_icon_url;
  final String banner_background_image_url;
  final String description_html;
  final double created;
  final String banner_background_color;
  final String mobile_banner_image;
  final String public_description;

  SubReddit({
    required this.title,
    required this.subscribers,
    required this.icon_img,
    required this.display_name_prefixed,
    required this.community_icon_url,
    required this.banner_background_image_url,
    required this.description_html,
    required this.created,
    required this.banner_background_color,
    required this.mobile_banner_image,
    required this.public_description,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subscribers': subscribers,
      'icon_img': icon_img,
      'display_name_prefixed': display_name_prefixed,
      'community_icon_url': community_icon_url,
      'banner_background_image_url': banner_background_image_url,
      'description_html': description_html,
      'created': created,
      'banner_background_color': banner_background_color,
      'mobile_banner_image': mobile_banner_image,
      'public_description': public_description,
    };
  }

  SubReddit.fromJson(Map<String, dynamic> res)
      : title = res['title'],
        subscribers = res['subscribers'],
        icon_img = res['icon_img'],
        display_name_prefixed = res['display_name_prefixed'],
        community_icon_url = res['community_icon_url'],
        banner_background_image_url = res['banner_background_image_url'],
        description_html = res['description_html'],
        created = res['created'],
        banner_background_color = res['banner_background_color'],
        mobile_banner_image = res['mobile_banner_image'],
        public_description = res['public_description'];

  @override
  String toString() {
    return 'SubReddit{title: $title, subscribers: $subscribers, community_icon_url: $community_icon_url, banner_background_image_url: $banner_background_image_url, description_html: $description_html, created: $created, banner_background_color: $banner_background_color, mobile_banner_image: $mobile_banner_image, public_description: $public_description}';
  }
}
