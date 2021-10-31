class UserPreferencies {
  final String accept_pms; // everyone / whitelisted
  final bool hide_from_robots;
  final bool allow_clicktracking;
  final bool third_party_data_personalized_ads;
  final bool third_party_site_data_personalized_ads;
  final bool show_location_based_recommendations;
  final bool third_party_site_data_personalized_content;
  final bool enable_followers;

  UserPreferencies(
      {required this.accept_pms,
      required this.hide_from_robots,
      required this.allow_clicktracking,
      required this.third_party_data_personalized_ads,
      required this.third_party_site_data_personalized_ads,
      required this.show_location_based_recommendations,
      required this.third_party_site_data_personalized_content,
      required this.enable_followers});
}
