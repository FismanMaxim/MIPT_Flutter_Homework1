import 'package:get_it/get_it.dart';
import 'package:tinder_cats/domain/cat_service.dart';
import 'package:tinder_cats/domain/liked_cats_service.dart';

final getIt = GetIt.instance;

void setupLocator() {
  getIt.registerLazySingleton(() => CatService());
  getIt.registerLazySingleton(() => LikedCatsService());
}
