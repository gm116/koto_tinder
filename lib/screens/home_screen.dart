import 'package:flutter/material.dart';
import '../services/cat_api.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  String imageUrl = '';
  String breedName = '';
  String origin = '';
  String temperament = '';
  String description = '';
  String lifeSpan = '';
  int likeCount = 0;
  int energyLevel = 0;
  int intelligence = 0;
  int childFriendly = 0;
  int dogFriendly = 0;
  int sheddingLevel = 0;
  bool hypoallergenic = false;
  String wikipediaUrl = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNewCat();
  }

  Future<void> _loadNewCat() async {
    setState(() {
      isLoading = true;
    });

    try {
      var cat = await CatApi.fetchRandomCat();
      String newImageUrl = cat['url'] ?? '';
      if (mounted) {
        await precacheImage(NetworkImage(newImageUrl), context);
      }
      setState(() {
        imageUrl = newImageUrl;
        breedName = cat['breedName'] ?? 'Неизвестная порода';
        origin = cat['origin'] ?? 'Неизвестно';
        temperament = cat['temperament'] ?? 'Нет данных';
        description = cat['description'] ?? 'Описание отсутствует';
        lifeSpan = cat['lifeSpan'] ?? 'Неизвестно';
        energyLevel = cat['energyLevel'] ?? 0;
        intelligence = cat['intelligence'] ?? 0;
        childFriendly = cat['childFriendly'] ?? 0;
        dogFriendly = cat['dogFriendly'] ?? 0;
        sheddingLevel = cat['sheddingLevel'] ?? 0;
        hypoallergenic = cat['hypoallergenic'] ?? false;
        wikipediaUrl = cat['wikipediaUrl'] ?? '';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        imageUrl = '';
        breedName = 'Ошибка загрузки';
        origin = 'Неизвестно';
        temperament = 'Нет данных';
        description = 'Описание отсутствует';
        lifeSpan = 'Неизвестно';
        energyLevel = 0;
        intelligence = 0;
        childFriendly = 0;
        dogFriendly = 0;
        sheddingLevel = 0;
        hypoallergenic = false;
        wikipediaUrl = '';
        isLoading = false;
      });
    }
  }

  void _likeCat() {
    setState(() {
      likeCount++;
    });
    _loadNewCat();
  }

  void _dislikeCat() {
    _loadNewCat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Кототиндер')),
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
                    key: Key(imageUrl),
                    direction: DismissDirection.horizontal,
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
                                  arguments: {
                                    'imageUrl': imageUrl,
                                    'breedName': breedName,
                                    'origin': origin,
                                    'temperament': temperament,
                                    'description': description,
                                    'lifeSpan': lifeSpan,
                                    'energyLevel': energyLevel,
                                    'intelligence': intelligence,
                                    'childFriendly': childFriendly,
                                    'dogFriendly': dogFriendly,
                                    'sheddingLevel': sheddingLevel,
                                    'hypoallergenic': hypoallergenic ? 1 : 0,
                                    'wikipediaUrl': wikipediaUrl,
                                  },
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
                                  : Container(color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  if (isLoading)
                    SizedBox(
                      width: 400,
                      height: 500,
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.green,
                          ),
                          strokeWidth: 6.0,
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
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    );
  }
}

class _LikeCountText extends StatelessWidget {
  final int likeCount;

  const _LikeCountText({required this.likeCount});

  @override
  Widget build(BuildContext context) {
    return Text('Лайков: $likeCount', style: TextStyle(fontSize: 18));
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
