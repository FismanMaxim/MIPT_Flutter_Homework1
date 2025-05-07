import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;

import 'package:tinder_cats/data/cat_model.dart';
import 'package:tinder_cats/domain/cat_service.dart';

import '../mocks.mocks.dart';

void main() {
  late MockClient mockClient;
  late CatService catService;

  setUp(() {
    mockClient = MockClient();
    catService = CatService(client: mockClient);
  });

  group('CatService', () {
    test('fetchRandomCats returns list of Cat when response is successful',
        () async {
      // Arrange
      const mockCatId = 'abc123';
      final catSearchResponse = jsonEncode([
        {'id': mockCatId}
      ]);

      final catDetailsResponse = jsonEncode({
        'id': mockCatId,
        'url': 'https://some.url/cat.jpg',
        'breeds': [
          {
            'name': 'Abyssinian',
            'description': 'A breed of domestic short-haired cats.',
            'temperament': 'Active, Energetic, Independent',
          }
        ]
      });

      // Mock the first call (search)
      when(mockClient.get(Uri.parse(
        'https://api.thecatapi.com/v1/images/search?has_breeds=1&limit=1',
      ))).thenAnswer((_) async => http.Response(catSearchResponse, 200));

      // Mock the second call (details)
      when(mockClient.get(Uri.parse(
        'https://api.thecatapi.com/v1/images/$mockCatId',
      ))).thenAnswer((_) async => http.Response(catDetailsResponse, 200));

      // Act
      final cats = await catService.fetchRandomCats(1);

      // Assert
      expect(cats, isA<List<Cat>>());
      expect(cats.length, 1);
      expect(cats.first.id, mockCatId);
      expect(cats.first.url, 'https://some.url/cat.jpg');
      expect(cats.first.breedName, 'Abyssinian');
    });

    test('fetchRandomCats throws exception on bad status code', () async {
      when(mockClient.get(any))
          .thenAnswer((_) async => http.Response('error', 500));

      expect(() async => await catService.fetchRandomCats(1), throwsException);
    });

    test('fetchCatDetails throws exception on bad status code', () async {
      when(mockClient.get(any))
          .thenAnswer((_) async => http.Response('error', 404));

      expect(() async => await catService.fetchCatDetails('invalid'),
          throwsException);
    });

    test('fetchRandomCats throws exception if count > 10', () async {
      expect(() => catService.fetchRandomCats(11), throwsException);
    });
  });
}
