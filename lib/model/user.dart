class User {
  final String name;
  final String namePrefixed;
  final String description;
  final bool banner;
  final String bannerURL;
  final String iconURL;

  User({
    required this.name,
    required this.namePrefixed,
    required this.description,
    required this.banner,
    required this.bannerURL,
    required this.iconURL,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'namePrefixed': namePrefixed,
      'description': description,
      'banner': banner,
      'bannerURL': bannerURL,
      'iconURL': iconURL,
    };
  }

  User.fromJson(Map<String, dynamic> res)
      : name = res['name'],
        namePrefixed = res['namePrefixed'],
        description = res['description'],
        banner = res['banner'],
        bannerURL = res['bannerURL'],
        iconURL = res['iconURL'];

  @override
  String toString() {
    return 'User{name: $name, namePrefixed: $namePrefixed, description: $description, banner: $banner, bannerURL: $bannerURL, iconURL: $iconURL}';
  }
}
