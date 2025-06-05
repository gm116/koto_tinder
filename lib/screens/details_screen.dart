import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:translator/translator.dart';
import '../models/cat.dart';

class DetailsScreen extends StatelessWidget {
  const DetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Cat? cat = ModalRoute.of(context)?.settings.arguments as Cat?;
    if (cat == null) {
      return Scaffold(body: Center(child: Text('Cat not found')));
    }

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity == null) return;
        double velocity = details.primaryVelocity!;
        if (velocity > 500) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 350,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Hero(
                  tag: cat.url,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      cat.url.isNotEmpty
                          ? Image.network(cat.url, fit: BoxFit.cover)
                          : Container(color: Colors.grey),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 40,
                          color: Colors.black.withValues(alpha: 0.4),
                        ),
                      ),
                      Positioned(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Text(
                            cat.breedName,
                            style: const TextStyle(
                              fontSize: 28,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildInfoText(
                      '${AppLocalizations.of(context).origin}: ${cat.origin}',
                      fontSize: 18,
                      isBold: true,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    _buildInfoText(
                      '${AppLocalizations.of(context).lifeSpan}: ${cat.lifeSpan} ${Localizations.localeOf(context).languageCode == 'ru' ? 'лет' : 'years'}',
                      textAlign: TextAlign.justify,
                    ),
                    FutureBuilder<String>(
                      future:
                          Localizations.localeOf(context).languageCode == 'ru'
                              ? GoogleTranslator()
                                  .translate(
                                    cat.temperament,
                                    from: 'en',
                                    to: 'ru',
                                  )
                                  .then((result) => result.text)
                              : Future.value(cat.temperament),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return _buildInfoText(
                            '${AppLocalizations.of(context).temperament}: Загрузка...',
                            textAlign: TextAlign.justify,
                          );
                        } else if (snapshot.hasError) {
                          return _buildInfoText(
                            '${AppLocalizations.of(context).temperament}: ${cat.temperament}',
                            textAlign: TextAlign.justify,
                          );
                        } else {
                          return _buildInfoText(
                            '${AppLocalizations.of(context).temperament}: ${snapshot.data}',
                            textAlign: TextAlign.justify,
                          );
                        }
                      },
                    ),
                    FutureBuilder<String>(
                      future:
                          Localizations.localeOf(context).languageCode == 'ru'
                              ? GoogleTranslator()
                                  .translate(
                                    cat.description,
                                    from: 'en',
                                    to: 'ru',
                                  )
                                  .then((result) => result.text)
                              : Future.value(cat.description),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return _buildInfoText(
                            '${AppLocalizations.of(context).description}: Загрузка...',
                            textAlign: TextAlign.justify,
                          );
                        } else if (snapshot.hasError) {
                          return _buildInfoText(
                            '${AppLocalizations.of(context).description}: ${cat.description}',
                            textAlign: TextAlign.justify,
                          );
                        } else {
                          return _buildInfoText(
                            '${AppLocalizations.of(context).description}: ${snapshot.data}',
                            textAlign: TextAlign.justify,
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildSectionTitle(
                              AppLocalizations.of(
                                context,
                              ).additionalCharacteristics,
                            ),
                            const SizedBox(height: 10),
                            _buildCharacteristic(
                              AppLocalizations.of(context).energy,
                              cat.energyLevel,
                            ),
                            _buildCharacteristic(
                              AppLocalizations.of(context).intelligence,
                              cat.intelligence,
                            ),
                            _buildCharacteristic(
                              AppLocalizations.of(context).childFriendly,
                              cat.childFriendly,
                            ),
                            _buildCharacteristic(
                              AppLocalizations.of(context).dogFriendly,
                              cat.dogFriendly,
                            ),
                            _buildCharacteristic(
                              AppLocalizations.of(context).sheddingLevel,
                              cat.sheddingLevel,
                            ),
                            const SizedBox(height: 10),
                            _buildInfoText(
                              cat.hypoallergenic
                                  ? AppLocalizations.of(
                                    context,
                                  ).hypoallergenicYes
                                  : AppLocalizations.of(
                                    context,
                                  ).hypoallergenicNo,
                              isBold: true,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoText(
    String text, {
    double fontSize = 16,
    bool isBold = false,
    TextAlign textAlign = TextAlign.start,
  }) {
    return Text(
      text,
      textAlign: textAlign,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        fontFamily: 'Montserrat',
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        fontFamily: 'Montserrat',
      ),
    );
  }

  Widget _buildCharacteristic(String title, int level) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$title: ',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Montserrat',
            ),
          ),
          Row(
            children: List.generate(
              level,
              (index) => const Icon(Icons.star, color: Colors.amber, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
