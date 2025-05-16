import 'package:flutter/material.dart';
import 'package:translator/translator.dart';

class BreedText extends StatelessWidget {
  final String breedName;

  const BreedText({required this.breedName, super.key});

  @override
  Widget build(BuildContext context) {
    final String languageCode = Localizations.localeOf(context).languageCode;

    if (languageCode != 'ru') {
      return Text(
        breedName,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          fontFamily: 'Montserrat',
        ),
      );
    }

    return FutureBuilder<String>(
      future: GoogleTranslator()
          .translate(breedName, from: 'en', to: 'ru')
          .then((result) => result.text),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text(
            'Загрузка...',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Montserrat',
            ),
          );
        } else if (snapshot.hasError) {
          return Text(
            breedName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Montserrat',
            ),
          );
        } else {
          return Text(
            snapshot.data ?? breedName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Montserrat',
            ),
          );
        }
      },
    );
  }
}
