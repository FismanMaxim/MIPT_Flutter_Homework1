import 'package:tinder_cats/data/cat_model.dart';

class LikedCat {
  final Cat cat;
  final DateTime likedAt;

  LikedCat({
    required this.cat,
    DateTime? likedAt,
  }) : likedAt = likedAt ?? DateTime.now();
}
