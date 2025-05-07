import 'package:flutter/foundation.dart';
import 'package:tinder_cats/data/cat_model.dart';
import 'package:tinder_cats/data/liked_cat.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LikedCatsService extends ChangeNotifier {
  final List<LikedCat> _likedCats = [];
  String? _currentFilter;

  static const _storageKey = 'liked_cats';

  LikedCatsService() {
    _loadFromStorage();
  }

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
      _saveToStorage();
    }
  }

  void removeLikedCat(String catId) {
    _likedCats.removeWhere((lc) => lc.cat.id == catId);
    notifyListeners();
    _saveToStorage();
  }

  void clearAll() {
    _likedCats.clear();
    notifyListeners();
    _saveToStorage();
  }

  void setFilter(String? breed) {
    _currentFilter = breed;
    notifyListeners();
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _likedCats.map((lc) => json.encode(lc.toJson())).toList();
    await prefs.setStringList(_storageKey, jsonList);
  }

  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_storageKey);
    if (jsonList != null) {
      _likedCats.clear();
      _likedCats.addAll(
          jsonList.map((jsonStr) => LikedCat.fromJson(json.decode(jsonStr))));
      notifyListeners();
    }
  }
}
