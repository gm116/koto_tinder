import 'package:flutter/material.dart';
import '../services/cat_api.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final List<Map<String, dynamic>> _catQueue = [];
  int likeCount = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeQueue();
  }

  Future<void> _initializeQueue() async {
    List<Future> futures = [];
    for (int i = 0; i < 10; i++) {
      futures.add(_addCatToQueue());
    }
    await Future.wait(futures);
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _addCatToQueue() async {
    setState(() {
      isLoading = true;
    });
    try {
      var cat = await CatApi.fetchRandomCat();
      String newImageUrl = cat['url'] ?? '';
      if (mounted && newImageUrl.isNotEmpty) {
        await precacheImage(NetworkImage(newImageUrl), context);
      }
      setState(() {
        _catQueue.add(cat);
        isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Ошибка загрузки кота')));
      }
    }
  }

  void _likeCat() {
    setState(() {
      likeCount++;
      if (_catQueue.isNotEmpty) {
        _catQueue.removeAt(0);
      }
    });

    if (_catQueue.length <= 1) {
      _initializeQueue();
    }
  }

  void _dislikeCat() {
    setState(() {
      if (_catQueue.isNotEmpty) {
        _catQueue.removeAt(0);
      }
    });
    if (_catQueue.length <= 1) {
      _initializeQueue();
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic>? currentCat =
        _catQueue.isNotEmpty ? _catQueue.first : null;

    String imageUrl = currentCat?['url'] ?? '';
    String breedName = currentCat?['breedName'] ?? 'Загрузка...';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Кототиндер',
          style: TextStyle(
            fontSize: 28,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 400,
              height: 500,
              child: Stack(
                children: [
                  Dismissible(
                    key: Key(imageUrl.isNotEmpty ? imageUrl : 'empty'),
                    direction:
                        isLoading
                            ? DismissDirection.none
                            : DismissDirection.horizontal,
                    confirmDismiss: (direction) async {
                      if (direction == DismissDirection.startToEnd) {
                        _likeCat();
                      } else if (direction == DismissDirection.endToStart) {
                        _dislikeCat();
                      }
                      return false;
                    },
                    child: GestureDetector(
                      onTap:
                          isLoading
                              ? null
                              : () {
                                Navigator.pushNamed(
                                  context,
                                  '/details',
                                  arguments: currentCat,
                                );
                              },
                      child: Container(
                        width: 400,
                        height: 500,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              spreadRadius: 2,
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child:
                              imageUrl.isNotEmpty
                                  ? Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    width: 400,
                                    height: 500,
                                  )
                                  : null,
                        ),
                      ),
                    ),
                  ),
                  if (isLoading || currentCat == null)
                    SizedBox(
                      width: 400,
                      height: 500,
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.grey,
                          ),
                          strokeWidth: 5.0,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 20),
            _BreedText(breedName: breedName),
            _LikeCountText(likeCount: likeCount),
            SizedBox(height: 30),
            LikeDislikeButtons(
              onLike: _likeCat,
              onDislike: _dislikeCat,
              isLoading: isLoading,
            ),
          ],
        ),
      ),
    );
  }
}

class _BreedText extends StatelessWidget {
  final String breedName;

  const _BreedText({required this.breedName});

  @override
  Widget build(BuildContext context) {
    return Text(
      breedName,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        fontFamily: 'Montserrat',
      ),
    );
  }
}

class _LikeCountText extends StatelessWidget {
  final int likeCount;

  const _LikeCountText({required this.likeCount});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Лайков: $likeCount',
      style: TextStyle(fontSize: 18, fontFamily: 'Montserrat'),
    );
  }
}

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
  LikeDislikeButtonsState createState() => LikeDislikeButtonsState();
}

class LikeDislikeButtonsState extends State<LikeDislikeButtons>
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
      duration: Duration(milliseconds: 100),
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
        SizedBox(width: 80),
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
                offset: Offset(0, 5),
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
