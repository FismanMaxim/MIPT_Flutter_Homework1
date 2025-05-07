import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tinder_cats/data/cat_model.dart';

class CatService {
  final http.Client _client;
  final String _baseUrl = 'https://api.thecatapi.com/v1';

  CatService({http.Client? client}) : _client = client ?? http.Client();

  Future<Cat> fetchRandomCat() async {
    return (await fetchRandomCats(1)).first;
  }

  Future<List<Cat>> fetchRandomCats(int count) async {
    if (count > 10) {
      throw Exception(
          "Backend API does not allow retrieving more than 10 cats without the API key");
    }

    final response = await _client
        .get(Uri.parse('$_baseUrl/images/search?has_breeds=1&limit=$count'))
        .timeout(const Duration(seconds: 3));

    if (response.statusCode != 200) {
      throw Exception('Failed to load cat');
    }

    final List<dynamic> jsons = json.decode(response.body);
    final List<Future<Cat>> futures =
        jsons.map((json) => fetchCatDetails(json['id'])).toList();

    return Future.wait(futures);
  }

  Future<Cat> fetchCatDetails(String id) async {
    final response = await _client
        .get(Uri.parse('$_baseUrl/images/$id'))
        .timeout(const Duration(seconds: 3));

    if (response.statusCode != 200) {
      throw Exception('Failed to load cat details');
    }

    return Cat.fromJson(json.decode(response.body));
  }
}
