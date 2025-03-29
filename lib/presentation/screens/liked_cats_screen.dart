import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tinder_cats/data/liked_cat.dart';
import 'package:tinder_cats/di/injector.dart';
import 'package:tinder_cats/domain/liked_cats_service.dart';
import 'package:tinder_cats/presentation/screens/details_screen.dart';
import 'package:intl/intl.dart';

class LikedCatsScreen extends StatefulWidget {
  const LikedCatsScreen({super.key});

  @override
  State<LikedCatsScreen> createState() => _LikedCatsScreenState();
}

class _LikedCatsScreenState extends State<LikedCatsScreen> {
  final List<String> emptyStatePhrases = [
    "No Purr-fect Matches Yet!",
    "Your Cat-alog in Empty!",
    "Your Purr-sonal Collection Awaits!",
    "No Kitty Chemistry Yet!",
  ];
  final LikedCatsService _likedCatsService = Injector.likedCatsService;

  String? _selectedBreed;

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sentiment_dissatisfied,
              size: 64,
              color: Colors.orange[300],
            ),
            const SizedBox(height: 16),
            Text(
              emptyStatePhrases[Random().nextInt(emptyStatePhrases.length)],
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Swipe right on cats you like\nand they\'ll appear here',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.pets),
              label: const Text('Start Swiping'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.orange[400],
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRemoveDialog(BuildContext context, LikedCat likedCat) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove this cat?'),
        content: Text(
            '${likedCat.cat.breedName} was liked on ${DateFormat.yMMMd().format(likedCat.likedAt)}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _likedCatsService.removeLikedCat(likedCat.cat.id);
              });
              Navigator.pop(context);
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear all liked cats?'),
        content: const Text('This will remove all your cat crushes'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _likedCatsService.clearAll();
              Navigator.pop(context);
            },
            child: const Text('Clear All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final likedCats = _likedCatsService.displayedLikedCats;

    return Scaffold(
        appBar: AppBar(
          title: const Text('Likes'),
          actions: [
            _buildBreedFilter(),
            if (likedCats.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.delete_sweep),
                tooltip: 'Clear All',
                onPressed: () => _showClearAllDialog(context),
              ),
          ],
        ),
        body: ListenableBuilder(
            listenable: _likedCatsService,
            builder: (context, _) {
              final displayedCats = _likedCatsService.displayedLikedCats;

              if (displayedCats.isEmpty) return _emptyState(context);

              return ListView.builder(
                itemCount: displayedCats.length,
                itemBuilder: (context, index) =>
                    _catCard(context, displayedCats[index]),
              );
            }));
  }

  Widget _catCard(BuildContext context, LikedCat likedCat) {
    var theme = Theme.of(context);
    return Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: likedCat.cat.url,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[200],
                width: 50,
                height: 50,
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[200],
                width: 50,
                height: 50,
                child: const Icon(Icons.error),
              ),
            ),
          ),
          title: Text(
            likedCat.cat.breedName,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Liked on ${DateFormat.yMMMd().add_jm().format(likedCat.likedAt)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              if (likedCat.cat.temperament.isNotEmpty)
                Text(
                  likedCat.cat.temperament,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
            ],
          ),
          trailing: IconButton(
            icon: Icon(
              Icons.favorite,
              color: Colors.red[400],
            ),
            onPressed: () => _showRemoveDialog(context, likedCat),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailScreen(cat: likedCat.cat),
              ),
            );
          },
        ));
  }

  Widget _buildBreedFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: DropdownButton<String>(
        value: _selectedBreed,
        hint: const Text('Filter'),
        items: [
          const DropdownMenuItem(
            value: null,
            child: Text('All Breeds'),
          ),
          ..._likedCatsService.availableBreeds.map(
            (breed) => DropdownMenuItem(
              value: breed,
              child: Text(breed),
            ),
          ),
        ],
        onChanged: (breed) {
          setState(() => _selectedBreed = breed);
          _likedCatsService.setFilter(breed);
        },
      ),
    );
  }
}
