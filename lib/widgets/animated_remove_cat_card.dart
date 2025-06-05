import 'package:flutter/material.dart';
import '../models/cat.dart';
import '../widgets/cat_card.dart';

class AnimatedRemoveCatCard extends StatefulWidget {
  final Cat cat;
  final VoidCallback onRemove;
  final VoidCallback onTap;

  const AnimatedRemoveCatCard({
    super.key,
    required this.cat,
    required this.onRemove,
    required this.onTap,
  });

  @override
  State<AnimatedRemoveCatCard> createState() => _AnimatedRemoveCatCardState();
}

class _AnimatedRemoveCatCardState extends State<AnimatedRemoveCatCard> {
  double opacity = 1.0;

  void removeWithFade() async {
    setState(() {
      opacity = 0.0;
    });
    await Future.delayed(const Duration(milliseconds: 220));
    widget.onRemove();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: opacity,
      child: CatCard(
        cat: widget.cat,
        onRemove: removeWithFade,
        onTap: widget.onTap,
      ),
    );
  }
}
