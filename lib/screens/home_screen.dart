import 'package:flutter/material.dart';
import '../services/cat_api.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
      setState(() {
        imageUrl = cat['url'] ?? '';
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
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: isLoading
                      ? Center(child: CircularProgressIndicator())
                      : GestureDetector(
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
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              breedName,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Лайков: $likeCount', style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.thumb_down, color: Colors.red, size: 40),
                  onPressed: isLoading ? null : _dislikeCat,
                ),
                SizedBox(width: 20),
                IconButton(
                  icon: Icon(Icons.thumb_up, color: Colors.green, size: 40),
                  onPressed: isLoading ? null : _likeCat,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
