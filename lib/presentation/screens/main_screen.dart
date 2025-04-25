import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tinder_cats/data/cat_model.dart';
import 'package:tinder_cats/di/injector.dart';
import 'package:tinder_cats/domain/cat_service.dart';
import 'package:tinder_cats/domain/liked_cats_service.dart';
import 'package:tinder_cats/presentation/components/like_button.dart';
import 'package:tinder_cats/presentation/screens/details_screen.dart';
import 'package:tinder_cats/utils/network_utils.dart';

import 'liked_cats_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  final CatService _catService = Injector.catService;
  final LikedCatsService _likedCatsService = Injector.likedCatsService;
  Cat? _currentCat;
  bool _isNetworkError = false;

  @override
  void initState() {
    super.initState();
    _loadNextCat();
  }

  Future<void> _loadNextCat() async {
    try {
      final hasConnection = await NetworkUtils.hasInternetConnection();
      if (!hasConnection) {
        setState(() => _isNetworkError = true);
        return;
      }

      setState(() => _isNetworkError = false);
      Cat? newCat = await _catService.fetchRandomCat();
      if (mounted) {
        setState(() => _currentCat = newCat);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isNetworkError = true);
      }
    }
  }

  void _showNetworkErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('No Internet Connection'),
        content: const Text('Please check your network and try again'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _loadNextCat();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
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
      _likedCatsService.addLikedCat(_currentCat!);
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
    if (_isNetworkError && _currentCat == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showNetworkErrorDialog();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Cat Tinder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LikedCatsScreen(),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
                child: Text('Likes: ${_likedCatsService.countLikedCats}')),
          ),
        ],
      ),
      body: _currentCat == null
          ? Center(child: CircularProgressIndicator())
          : _catCard(),
    );
  }

  GestureDetector _catCard() {
    return GestureDetector(
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
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                    SizedBox(height: 7),
                    Text(
                      _currentCat!.breedName,
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.w400),
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
    );
  }
}
