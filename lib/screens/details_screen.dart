import 'package:flutter/material.dart';

class DetailsScreen extends StatelessWidget {
  const DetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String imageUrl = args?['imageUrl'] ?? '';
    final String breedName = args?['breedName'] ?? 'Unknown';
    final String origin = args?['origin'] ?? 'Unknown';
    final String temperament = args?['temperament'] ?? 'Unknown';
    final String description =
        args?['description'] ?? 'No description available';
    final String lifeSpan = args?['lifeSpan'] ?? 'Unknown';
    final int energyLevel = args?['energyLevel'] ?? 0;
    final int intelligence = args?['intelligence'] ?? 0;
    final int childFriendly = args?['childFriendly'] ?? 0;
    final int dogFriendly = args?['dogFriendly'] ?? 0;
    final int sheddingLevel = args?['sheddingLevel'] ?? 0;
    final bool hypoallergenic = args?['hypoallergenic'] == 1;
    final String wikipediaUrl = args?['wikipediaUrl'] ?? '';

    return Scaffold(
      appBar: AppBar(title: Text(breedName)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            imageUrl.isNotEmpty
                ? Image.network(imageUrl, height: 300)
                : Text('Ошибка загрузки изображения'),
            SizedBox(height: 20),
            Text(
              'Страна: $origin',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Продолжительность жизни: $lifeSpan лет',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'Характер: $temperament',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'Описание: $description',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'Дополнительные характеристики:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            _buildCharacteristic('Энергичность', energyLevel),
            _buildCharacteristic('Интеллект', intelligence),
            _buildCharacteristic('Дружелюбность к детям', childFriendly),
            _buildCharacteristic('Дружелюбность к собакам', dogFriendly),
            _buildCharacteristic('Уровень линьки', sheddingLevel),
            SizedBox(height: 10),
            Text(
              hypoallergenic ? '✅ Гипоаллергенный' : '❌ Не гипоаллергенный',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (wikipediaUrl.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: TextButton(
                  onPressed: () => _openWikipedia(wikipediaUrl, context),
                  child: Text(
                    'Подробнее на Wikipedia',
                    style: TextStyle(fontSize: 16, color: Colors.blue),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCharacteristic(String title, int level) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$title: ',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Row(
          children: List.generate(
            level,
            (index) => Icon(Icons.star, color: Colors.amber, size: 20),
          ),
        ),
      ],
    );
  }

  void _openWikipedia(String url, BuildContext context) {
    // TODO: сделать редирект на браузер
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Открытие Wikipedia: $url')));
  }
}
