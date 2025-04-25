import 'package:flutter/foundation.dart';
import 'package:tinder_cats/data/cat_model.dart';
import 'package:tinder_cats/data/liked_cat.dart';

class LikedCatsService extends ChangeNotifier {
  final List<LikedCat> _likedCats = [];
  String? _currentFilter;

  List<LikedCat> get allLikedCats => _likedCats;
  List<LikedCat> get displayedLikedCats => _currentFilter == null
      ? _likedCats
      : _likedCats.where((cat) => cat.cat.breedName == _currentFilter).toList();
  List<String> get availableBreeds =>
      _likedCats.map((cat) => cat.cat.breedName).toSet().toList();

  get countLikedCats => _likedCats.length;

  void addLikedCat(Cat cat) {
    if (!_likedCats.any((lc) => lc.cat.id == cat.id)) {
      _likedCats.add(LikedCat(cat: cat));
      _likedCats.sort((a, b) => b.likedAt.compareTo(a.likedAt));
      notifyListeners();
    }
  }

  void removeLikedCat(String catId) {
    _likedCats.removeWhere((lc) => lc.cat.id == catId);
    notifyListeners();
  }

  void clearAll() {
    _likedCats.clear();
    notifyListeners();
  }

  void setFilter(String? breed) {
    _currentFilter = breed;
    notifyListeners();
  }
}
