import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:translator/translator.dart';

class CatApi {
  static const String _searchUrl =
      'https://api.thecatapi.com/v1/images/search?has_breeds=1';

  static Future<Map<String, dynamic>> fetchRandomCat() async {
    final searchResponse = await http.get(Uri.parse(_searchUrl));
    if (searchResponse.statusCode == 200) {
      List<dynamic> searchData = json.decode(searchResponse.body);
      if (searchData.isNotEmpty && searchData[0] != null) {
        var cat = searchData[0];
        String imageId = cat['id'];
        String imageUrl = cat['url'];

        final detailsResponse = await http.get(
          Uri.parse('https://api.thecatapi.com/v1/images/$imageId'),
        );
        if (detailsResponse.statusCode == 200) {
          var detailsData = json.decode(detailsResponse.body);
          var breed =
          (detailsData['breeds'] != null && detailsData['breeds'].isNotEmpty)
              ? detailsData['breeds'][0]
              : null;

          final translator = GoogleTranslator();
          var translatedBreedName = await translator.translate(breed?['name'] ?? 'Unknown', to: 'ru');
          var translatedOrigin = await translator.translate(breed?['origin'] ?? 'Unknown', to: 'ru');
          var translatedTemperament = await translator.translate(breed?['temperament'] ?? 'Unknown', to: 'ru');
          var translatedDescription = await translator.translate(breed?['description'] ?? 'No description available', to: 'ru');

          return {
            'url': imageUrl,
            'breedName': translatedBreedName.text,
            'origin': translatedOrigin.text,
            'temperament': translatedTemperament.text,
            'description': translatedDescription.text,
            'lifeSpan': breed?['life_span'] ?? 'Неизвестно',
            'energyLevel': breed?['energy_level'] ?? 0,
            'intelligence': breed?['intelligence'] ?? 0,
            'childFriendly': breed?['child_friendly'] ?? 0,
            'dogFriendly': breed?['dog_friendly'] ?? 0,
            'sheddingLevel': breed?['shedding_level'] ?? 0,
            'hypoallergenic': breed?['hypoallergenic'] == 1,
            'wikipediaUrl': breed?['wikipedia_url'] ?? '',
          };
        }
      }
    }
    throw Exception('Ошибка загрузки данных');
  }
}