import 'dart:async';
import 'package:flutter/material.dart';
import '../services/cat_api.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../cubit/liked_cats_cubit.dart';
import '../models/cat.dart';
import '../di/di.dart';
import '../widgets/like_count_text.dart';
import '../widgets/breed_text.dart';
import '../widgets/like_dislike_buttons.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
  bool _isOffline = false;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _initializeQueue();
    _initConnectivity();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      results,
    ) {
      final result =
          results.isNotEmpty ? results.first : ConnectivityResult.none;
      _updateConnectionStatus(result);
    });
  }

  Future<void> _initConnectivity() async {
    final connectivity = Connectivity();
    final results = await connectivity.checkConnectivity();
    final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
    _updateConnectionStatus(result);
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    final offline = result == ConnectivityResult.none;
    if (_isOffline != offline) {
      setState(() {
        _isOffline = offline;
      });
      final message =
          offline
              ? AppLocalizations.of(context).offline
              : AppLocalizations.of(context).online;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
          backgroundColor: offline ? Colors.red : Colors.green,
        ),
      );

      if (!offline) {
        if (_catQueue.length < 5) {
          _initializeQueue();
        }
      }
    }
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> _initializeQueue() async {
    if (_isOffline) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    List<Future> futures = [];
    for (int i = 0; i < 20; i++) {
      futures.add(_addCatToQueue());
    }
    await Future.wait(futures);
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _cacheImage(String imageUrl) async {
    final completer = Completer<void>();
    final imageProvider = CachedNetworkImageProvider(imageUrl);
    final stream = imageProvider.resolve(const ImageConfiguration());
    late final ImageStreamListener listener;

    listener = ImageStreamListener(
      (image, synchronousCall) {
        completer.complete();
        stream.removeListener(listener);
      },
      onError: (error, stackTrace) {
        completer.complete();
        stream.removeListener(listener);
      },
    );

    stream.addListener(listener);

    await completer.future;
  }

  Future<void> _addCatToQueue() async {
    if (_isOffline) {
      setState(() {
        isLoading = false;
      });
      return;
    }
    setState(() {
      isLoading = true;
    });
    try {
      var cat = await CatApi().fetchRandomCat();
      String imageUrl = cat['url'] ?? '';
      if (imageUrl.isNotEmpty) {
        try {
          await _cacheImage(imageUrl);
        } catch (e) {
          // скипаем ошибку
        }
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

    if (_catQueue.length <= 1 && !_isOffline) {
      _initializeQueue();
    }
  }

  void _dislikeCat() {
    setState(() {
      if (_catQueue.isNotEmpty) {
        _catQueue.removeAt(0);
      }
    });
    if (_catQueue.length <= 1 && !_isOffline) {
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
        bottom:
            _isOffline
                ? PreferredSize(
                  preferredSize: const Size.fromHeight(24.0),
                  child: Container(
                    color: Colors.red,
                    height: 24,
                    child: Center(
                      child: Text(
                        AppLocalizations.of(context).offlineMode,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                )
                : null,
      ),
      body: SingleChildScrollView(
        child: Center(
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
                                color: Colors.black.withAlpha(50),
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
                                    ? CachedNetworkImage(
                                      imageUrl: imageUrl,
                                      fit: BoxFit.cover,
                                      width: 400,
                                      height: 500,
                                      placeholder:
                                          (context, url) => const Center(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 3,
                                            ),
                                          ),
                                      errorWidget:
                                          (context, url, error) => const Center(
                                            child: Icon(
                                              Icons.broken_image,
                                              size: 48,
                                              color: Colors.grey,
                                            ),
                                          ),
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
      ),
    );
  }
}
