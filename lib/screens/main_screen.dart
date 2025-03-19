import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tinder_cats/client/cat_service.dart';
import 'package:tinder_cats/components/like_button.dart';
import 'package:tinder_cats/model/cat_model.dart';
import 'package:tinder_cats/screens/details_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  final CatService _catService = CatService();
  Cat? _currentCat;
  int _likeCount = 0;

  @override
  void initState() {
    super.initState();
    _loadNextCat();
  }

  Future<void> _loadNextCat() async {
    Cat? newCat = await _catService.fetchRandomCat();
    setState(() {
      _currentCat = newCat;
    });
  }

  void _handleSwipe(DragEndDetails details) {
    if (details.primaryVelocity! > 0) {
      _handleLike();
    } else if (details.primaryVelocity! < 0) {
      _handleDislike();
    }
  }

  void _handleLike() {
    setState(() {
      _likeCount++;
    });
    _loadNextCat();
  }

  void _handleDislike() {
    _loadNextCat();
  }

  void _navigateToDetailScreen() {
    if (_currentCat != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailScreen(cat: _currentCat!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cat Tinder'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(child: Text('Likes: $_likeCount')),
          ),
        ],
      ),
      body: _currentCat == null
          ? Center(child: CircularProgressIndicator())
          : GestureDetector(
              onHorizontalDragEnd: _handleSwipe,
              child: Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _navigateToDetailScreen,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CachedNetworkImage(
                              imageUrl: _currentCat!.url,
                              placeholder: (context, url) =>
                                  CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            ),
                            SizedBox(height: 7),
                            Text(
                              _currentCat!.breedName,
                              style: TextStyle(
                                  fontSize: 25, fontWeight: FontWeight.w400),
                            )
                          ],
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        LikeButton(onPressed: _handleDislike, isLike: false),
                        LikeButton(onPressed: _handleLike, isLike: true),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
