import 'package:flutter/material.dart';
import '../services/cat_api.dart';

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
                      onTap: () {
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
                  if (isLoading)
                    SizedBox(
                      width: 400,
                      height: 500,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
            ),
            SizedBox(height: 20),
            _BreedText(breedName: breedName),
            _LikeCountText(likeCount: likeCount),
            SizedBox(height: 40),
            _LikeDislikeButtons(
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

class _LikeDislikeButtons extends StatelessWidget {
  final VoidCallback onLike;
  final VoidCallback onDislike;
  final bool isLoading;

  const _LikeDislikeButtons({
    required this.onLike,
    required this.onDislike,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.thumb_down, color: Colors.red, size: 40),
          onPressed: isLoading ? null : onDislike,
        ),
        SizedBox(width: 80),
        IconButton(
          icon: Icon(Icons.thumb_up, color: Colors.green, size: 40),
          onPressed: isLoading ? null : onLike,
        ),
      ],
    );
  }
}
