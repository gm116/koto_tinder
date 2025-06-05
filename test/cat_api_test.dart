import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:koto_tinder/services/cat_api.dart';

class MockCatApi extends Mock implements CatApi {}

void main() {
  late MockCatApi mockCatApi;

  setUp(() {
    mockCatApi = MockCatApi();
  });

  test('fetchRandomCat возвращает замоканного кота', () async {
    final fakeCat = {
      'url': 'https://test.url/cat.jpg',
      'breedName': 'MockBreed',
      'origin': 'MockOrigin',
      'temperament': 'Friendly',
      'description': 'Test cat',
      'lifeSpan': '15',
      'energyLevel': 4,
      'intelligence': 4,
      'childFriendly': 5,
      'dogFriendly': 5,
      'sheddingLevel': 1,
      'hypoallergenic': true,
    };

    when(() => mockCatApi.fetchRandomCat()).thenAnswer((_) async => fakeCat);

    final result = await mockCatApi.fetchRandomCat();
    expect(result, fakeCat);
    expect(result['breedName'], 'MockBreed');
  });
}
