import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tinder_cats/data/cat_model.dart';
import 'package:tinder_cats/domain/liked_cats_service.dart';

void main() {
  late LikedCatsService service;

  final cat1 = Cat(
      id: '1',
      description: "",
      url: 'url1',
      breedName: 'Siamese',
      temperament: 'Playful');
  final cat2 = Cat(
      id: '2',
      description: "",
      url: 'url2',
      breedName: 'Persian',
      temperament: 'Calm');

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    service = LikedCatsService();
    await Future.delayed(
        const Duration(milliseconds: 10)); // wait for _loadFromStorage
  });

  test('initial list is empty', () {
    expect(service.allLikedCats, isEmpty);
    expect(service.displayedLikedCats, isEmpty);
    expect(service.availableBreeds, isEmpty);
  });

  test('addLikedCat adds a cat and persists it', () async {
    service.addLikedCat(cat1);
    expect(service.allLikedCats.length, 1);
    expect(service.allLikedCats.first.cat.id, '1');
    expect(service.countLikedCats, 1);

    // Adding the same cat again shouldn't duplicate
    service.addLikedCat(cat1);
    expect(service.allLikedCats.length, 1);
  });

  test('removeLikedCat removes the correct cat', () async {
    service.addLikedCat(cat1);
    service.addLikedCat(cat2);
    service.removeLikedCat('1');

    expect(service.allLikedCats.length, 1);
    expect(service.allLikedCats.first.cat.id, '2');
  });

  test('clearAll removes all liked cats', () async {
    service.addLikedCat(cat1);
    service.addLikedCat(cat2);
    service.clearAll();

    expect(service.allLikedCats, isEmpty);
  });

  test('setFilter filters displayed cats', () async {
    service.addLikedCat(cat1);
    service.addLikedCat(cat2);
    service.setFilter('Siamese');

    expect(service.displayedLikedCats.length, 1);
    expect(service.displayedLikedCats.first.cat.breedName, 'Siamese');
  });

  test('availableBreeds returns unique breed names', () async {
    service.addLikedCat(cat1);
    service.addLikedCat(cat2);
    expect(service.availableBreeds.toSet(), {'Siamese', 'Persian'});
  });

  test('data is saved and restored from storage', () async {
    service.addLikedCat(cat1);

    // Recreate service to simulate app restart
    final service2 = LikedCatsService();
    await Future.delayed(const Duration(milliseconds: 10));

    expect(service2.allLikedCats.length, 1);
    expect(service2.allLikedCats.first.cat.id, '1');
  });
}
