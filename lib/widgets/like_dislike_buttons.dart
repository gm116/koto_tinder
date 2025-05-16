import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LikeDislikeButtons extends StatefulWidget {
  final VoidCallback onLike;
  final VoidCallback onDislike;
  final bool isLoading;

  const LikeDislikeButtons({
    required this.onLike,
    required this.onDislike,
    required this.isLoading,
    super.key,
  });

  @override
  State<LikeDislikeButtons> createState() => _LikeDislikeButtonsState();
}

class _LikeDislikeButtonsState extends State<LikeDislikeButtons>
    with TickerProviderStateMixin {
  late AnimationController _likeController;
  late AnimationController _dislikeController;

  @override
  void initState() {
    super.initState();
    _likeController = _createController();
    _dislikeController = _createController();
  }

  AnimationController _createController() {
    return AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.9,
      upperBound: 1.0,
    )..value = 1.0;
  }

  @override
  void dispose() {
    _likeController.dispose();
    _dislikeController.dispose();
    super.dispose();
  }

  void _animateAndPerform(AnimationController controller, VoidCallback action) {
    if (widget.isLoading) return;
    controller.reverse().then((_) {
      action();
      controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildButton(
          icon: FontAwesomeIcons.xmark,
          color: Colors.red,
          onTap: () => _animateAndPerform(_dislikeController, widget.onDislike),
          controller: _dislikeController,
        ),
        const SizedBox(width: 80),
        _buildButton(
          icon: FontAwesomeIcons.solidHeart,
          color: Colors.green,
          onTap: () => _animateAndPerform(_likeController, widget.onLike),
          controller: _likeController,
        ),
      ],
    );
  }

  Widget _buildButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required AnimationController controller,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ScaleTransition(
        scale: controller,
        child: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10,
                spreadRadius: 2,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        color.withValues(alpha: 0.15),
                        color.withValues(alpha: 0.01),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              Center(child: FaIcon(icon, color: color, size: 32)),
            ],
          ),
        ),
      ),
    );
  }
}
