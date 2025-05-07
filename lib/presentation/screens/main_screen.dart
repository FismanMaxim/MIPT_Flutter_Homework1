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

  final List<Cat> _catQueue = [];
  Cat? _currentCat;
  bool _isNetworkError = false;

  @override
  void initState() {
    super.initState();
    _loadNextCat();
  }

  Future<void> _loadNextCat() async {
    if (_catQueue.isNotEmpty) {
      setState(() {
        _currentCat = _catQueue.removeAt(0);
      });
      return;
    }

    final hasConnection = await NetworkUtils.hasInternetConnection();
    if (!hasConnection) {
      if (!mounted) return;

      setState(() {
        _isNetworkError = true;
        _currentCat = null;
      });

      if (_catQueue.isEmpty && _currentCat == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No internet connection.'),
            duration: Duration(seconds: 4),
          ),
        );
      }
      return;
    }

    setState(() => _isNetworkError = false);

    try {
      if (_catQueue.length < 5) {
        List<Cat> newCats = await _catService
            .fetchRandomCats(5)
            .timeout(const Duration(seconds: 3));

        if (!mounted) return;

        for (final cat in newCats) {
          precacheImage(CachedNetworkImageProvider(cat.url), context);
        }

        setState(() {
          _catQueue.addAll(newCats);
        });
      }

      if (_currentCat == null && _catQueue.isNotEmpty) {
        if (!mounted) return;
        setState(() {
          _currentCat = _catQueue.removeAt(0);
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isNetworkError = true);

      if (_catQueue.isEmpty && _currentCat == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No internet connection.'),
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _handleSwipe(DragEndDetails details) {
    if (details.primaryVelocity! > 0) {
      _handleLike();
    } else if (details.primaryVelocity! < 0) {
      _handleDislike();
    }
  }

  void _handleLike() {
    if (_currentCat != null) {
      _likedCatsService.addLikedCat(_currentCat!);
    }
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
      body: _isNetworkError
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'No internet connection',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _loadNextCat,
                    child: Text('Retry'),
                  ),
                ],
              ),
            )
          : _currentCat == null
              ? Center(child: CircularProgressIndicator())
              : _catCard(),
    );
  }

  Widget _catCard() {
    return Column(
      children: [
        Expanded(
          child: GestureDetector(
            onHorizontalDragEnd: _handleSwipe,
            child: GestureDetector(
              onTap: _navigateToDetailScreen,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CachedNetworkImage(
                    imageUrl: _currentCat!.url,
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                  SizedBox(height: 7),
                  Text(
                    _currentCat!.breedName,
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.w400),
                  ),
                ],
              ),
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
    );
  }
}
