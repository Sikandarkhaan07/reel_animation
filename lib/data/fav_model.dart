class Favorite {
  String key;
  String qoute;
  String image;
  String auther;
  bool isFav;

  Favorite({
    required this.key,
    required this.image,
    required this.qoute,
    required this.isFav,
    required this.auther,
  });

  // Convert the Favorite object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'qoute': qoute,
      'image': image,
      'isFav': isFav,
      'auther': auther,
      'key': key
    };
  }

  // Create a Favorite object from a JSON map
  factory Favorite.fromJson(dynamic json) {
    return Favorite(
      image: json['image'] ??
          ' https://images.unsplash.com/photo-1433086966358-54859d0ed716?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8bmF0dXJlfGVufDB8fDB8fHww&w=1000&q=80',
      isFav: json['isFav'] ?? false,
      qoute: json['qoute'] ?? '',
      auther: json['auther'] ?? '',
      key: json['key'] ?? '',
    );
  }
}
