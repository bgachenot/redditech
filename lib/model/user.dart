class User {
  final String name;
  final String namePrefixed;
  final String description;
  final bool banner;
  final String bannerURL;
  final String iconURL;
  final int totalKarma;
  final double created;

  User({
    required this.name,
    required this.namePrefixed,
    required this.description,
    required this.banner,
    required this.bannerURL,
    required this.iconURL,
    required this.totalKarma,
    required this.created,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'namePrefixed': namePrefixed,
      'description': description,
      'banner': banner,
      'bannerURL': bannerURL,
      'iconURL': iconURL,
      'totalKarma': totalKarma,
      'created': created,
    };
  }

  User.fromJson(Map<String, dynamic> res)
      : name = res['name'],
        namePrefixed = res['namePrefixed'],
        description = res['description'],
        banner = res['banner'],
        bannerURL = res['bannerURL'],
        iconURL = res['iconURL'],
        totalKarma = res['totalKarma'],
        created = res['created'];

  @override
  String toString() {
    return 'User{name: $name, namePrefixed: $namePrefixed, description: $description, banner: $banner, bannerURL: $bannerURL, iconURL: $iconURL, totalKarma: $totalKarma, created, $created}';
  }
}
