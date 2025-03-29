import 'package:tinder_cats/domain/cat_service.dart';
import 'package:get_it/get_it.dart';
import 'package:tinder_cats/domain/liked_cats_service.dart';

class Injector {
  static CatService get catService => GetIt.I<CatService>();
  static LikedCatsService get likedCatsService => GetIt.I<LikedCatsService>();
}
