import 'package:flutter/material.dart';
import '../services/cat_api.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../cubit/liked_cats_cubit.dart';
import '../models/cat.dart';
import '../di/di.dart';
import '../widgets/like_count_text.dart';
import '../widgets/breed_text.dart';
import '../widgets/like_dislike_buttons.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onLocaleChange});

  final Function(Locale) onLocaleChange;

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).errorLoadingCat)),
        );
      }
    }
  }

  void _likeCat() {
    setState(() {
      likeCount++;
      if (_catQueue.isNotEmpty) {
        final cat = Cat.fromMap(_catQueue.first);
        sl<LikedCatsCubit>().likeCat(cat);
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
    String breedName =
        currentCat?['breedName'] ?? AppLocalizations.of(context).loading;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).appTitle,
          style: const TextStyle(
            fontSize: 28,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            tooltip: "Liked Cats",
            onPressed: () {
              Navigator.pushNamed(context, '/liked');
            },
          ),
          PopupMenuButton<Locale>(
            onSelected: (locale) {
              widget.onLocaleChange(locale);
            },
            itemBuilder:
                (context) => const [
                  PopupMenuItem(value: Locale('ru'), child: Text('🇷🇺RU')),
                  PopupMenuItem(value: Locale('en'), child: Text('🇺🇸EN')),
                ],
            icon: const Icon(Icons.language),
          ),
        ],
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
                          isLoading || currentCat == null
                              ? null
                              : () {
                                final cat = Cat.fromMap(currentCat);
                                Navigator.pushNamed(
                                  context,
                                  '/details',
                                  arguments: cat,
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
                              offset: const Offset(0, 5),
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
                    const SizedBox(
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
            const SizedBox(height: 20),
            BreedText(breedName: breedName),
            LikeCountText(likeCount: likeCount),
            const SizedBox(height: 30),
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
