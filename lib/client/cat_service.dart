import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tinder_cats/model/cat_model.dart';

class CatService {
  final String _baseUrl = 'https://api.thecatapi.com/v1';

  Future<Cat> fetchRandomCat() async {
    return (await fetchRandomCats(1)).first;
  }

  Future<List<Cat>> fetchRandomCats(int count) async {
    if (count > 10) {
      throw Exception(
          "Backend API does not allow to retrieve more than 10 cats without the API key");
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/images/search?has_breeds=1&limit=$count'),
    );

    if (response.statusCode != 200) throw Exception('Failed to load cat');

    final List<dynamic> jsons = json.decode(response.body);
    List<Future<Cat>> listOfFutures =
        jsons.map((json) async => await fetchCatDetails(json['id'])).toList();

    return (listOfFutures) async {
      List<Cat> cats = [];
      for (var future in listOfFutures) {
        cats.add(await future);
      }
      return cats;
    }(listOfFutures);
  }

  Future<Cat> fetchCatDetails(String id) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/images/$id'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load cat details');
    }

    return Cat.fromJson(json.decode(response.body));
  }
}
