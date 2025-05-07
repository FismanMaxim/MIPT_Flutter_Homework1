import 'package:tinder_cats/data/cat_model.dart';

class LikedCat {
  final Cat cat;
  final DateTime likedAt;

  LikedCat({
    required this.cat,
    DateTime? likedAt,
  }) : likedAt = likedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'cat': cat.toJson(),
        'likedAt': likedAt.toIso8601String(),
      };

  factory LikedCat.fromJson(Map<String, dynamic> json) {
    return LikedCat(
      cat: Cat.fromSimpleJson(json['cat']),
      likedAt: DateTime.parse(json['likedAt']),
    );
  }
}
