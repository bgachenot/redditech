class Trophies {
  final String icon_70_url;
  final int granted_at;
  final String icon_40_url;
  final String name;
  final String description;

  Trophies({
    required this.name,
    required this.description,
    required this.icon_70_url,
    required this.granted_at,
    required this.icon_40_url,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'icon_70_url': icon_70_url,
      'granted_at': granted_at,
      'icon_40_url': icon_40_url,
    };
  }

  Trophies.fromJson(Map<String, dynamic> res)
      : name = res['name'],
        description = res['description'],
        icon_70_url = res['icon_70_url'],
        granted_at = res['granted_at'],
        icon_40_url = res['icon_40_url'];

  @override
  String toString() {
    return 'User{name: $name, description: $description, icon_70_url: $icon_70_url, granted_at: $granted_at, icon_40_url: $icon_40_url}';
  }
}
