import 'package:flutter/material.dart';
import 'package:tinder_cats/data/cat_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DetailScreen extends StatelessWidget {
  final Cat cat;

  const DetailScreen({super.key, required this.cat});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(cat.breedName),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            CachedNetworkImage(
              imageUrl: cat.url,
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(cat.description),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Temperament: ${cat.temperament}'),
            ),
          ],
        ),
      ),
    );
  }
}
