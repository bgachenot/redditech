class AllAwardings {
  final int coin_price;
  final String id;
  final int coin_reward;
  final String icon_url; // useless
  final int icon_width; // useless
  final int static_icon_width;
  final String description;
  final int count;
  final String name;
  final String? icon_format; // useless
  final int icon_height;
  final String static_icon_url;

  AllAwardings({
    required this.coin_price,
    required this.id,
    required this.coin_reward,
    required this.icon_url,
    required this.icon_width,
    required this.static_icon_width,
    required this.description,
    required this.count,
    required this.name,
    required this.icon_format,
    required this.icon_height,
    required this.static_icon_url,
  });
}