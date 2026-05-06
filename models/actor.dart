class Actor {
  final String id;
  final String name;
  final String photoUrl;

  const Actor({
    required this.id,
    required this.name,
    required this.photoUrl,
  });

  factory Actor.fromJson(Map<String, dynamic> json) {
    return Actor(
      id: json['id'] as String,
      name: json['name'] as String,
      photoUrl: json['photoUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'photoUrl': photoUrl,
      };
}
