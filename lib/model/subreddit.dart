class SubReddit {
  final String display_name;
  final String title;
  final int active_user_count;
  final String? icon_img;
  final String display_name_prefixed;
  final int accounts_active;
  final int subscribers;
  final String name;
  final String? public_description;
  final bool user_has_favorited;
  final String? community_icon;
  final String? banner_background_image;
  final String? description_html;
  final double created;
  bool user_is_subscriber;
  final String? public_description_html;
  final bool accept_followers;
  final String? banner_img; // Can be '' or null
  final String? description;
  final String url;
  final String? mobile_banner_image;

  SubReddit({
    required this.display_name,
    required this.title,
    required this.active_user_count,
    required this.icon_img,
    required this.display_name_prefixed,
    required this.accounts_active,
    required this.subscribers,
    required this.name,
    required this.public_description,
    required this.user_has_favorited,
    required this.community_icon,
    required this.banner_background_image,
    required this.description_html,
    required this.created,
    required this.user_is_subscriber,
    required this.public_description_html,
    required this.accept_followers,
    required this.banner_img,
    required this.description,
    required this.url,
    required this.mobile_banner_image,
  });

// Map<String, dynamic> toJson() {
//   return {
//     'title': title,
//     'subscribers': subscribers,
//     'icon_img': icon_img,
//     'display_name_prefixed': display_name_prefixed,
//     'community_icon_url': community_icon_url,
//     'banner_background_image_url': banner_background_image_url,
//     'description_html': description_html,
//     'created': created,
//     'banner_background_color': banner_background_color,
//     'mobile_banner_image': mobile_banner_image,
//     'public_description': public_description,
//     'following': following,
//   };
// }
//
// SubReddit.fromJson(Map<String, dynamic> res)
//     : title = res['title'],
//       subscribers = res['subscribers'],
//       icon_img = res['icon_img'],
//       display_name_prefixed = res['display_name_prefixed'],
//       community_icon_url = res['community_icon_url'],
//       banner_background_image_url = res['banner_background_image_url'],
//       description_html = res['description_html'],
//       created = res['created'],
//       banner_background_color = res['banner_background_color'],
//       mobile_banner_image = res['mobile_banner_image'],
//       public_description = res['public_description'],
//       following = res['following'];
//
// @override
// String toString() {
//   return 'SubReddit{title: $title, subscribers: $subscribers, community_icon_url: $community_icon_url, banner_background_image_url: $banner_background_image_url, description_html: $description_html, created: $created, banner_background_color: $banner_background_color, mobile_banner_image: $mobile_banner_image, public_description: $public_description, following: $following}';
// }
}
