import 'package:flutter/material.dart';

class LikeButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLike;

  const LikeButton({super.key, required this.onPressed, required this.isLike});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(isLike ? Icons.thumb_up : Icons.thumb_down),
      onPressed: onPressed,
      color: isLike ? Colors.green : Colors.red,
    );
  }
}
