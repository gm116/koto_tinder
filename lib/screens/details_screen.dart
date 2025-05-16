import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:translator/translator.dart';

class DetailsScreen extends StatelessWidget {
  const DetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String imageUrl = args?['url'] ?? '';
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
                  tag: imageUrl,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      imageUrl.isNotEmpty
                          ? Image.network(imageUrl, fit: BoxFit.cover)
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
                            breedName,
                            style: TextStyle(
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
                      '${AppLocalizations.of(context).origin}: $origin',
                      fontSize: 18,
                      isBold: true,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    _buildInfoText(
                      '${AppLocalizations.of(context).lifeSpan}: $lifeSpan ${Localizations.localeOf(context).languageCode == 'ru' ? 'лет' : 'years'}',
                      textAlign: TextAlign.justify,
                    ),
                    FutureBuilder<String>(
                      future:
                          Localizations.localeOf(context).languageCode == 'ru'
                              ? GoogleTranslator()
                                  .translate(temperament, from: 'en', to: 'ru')
                                  .then((result) => result.text)
                              : Future.value(temperament),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return _buildInfoText(
                            '${AppLocalizations.of(context).temperament}: Загрузка...',
                            textAlign: TextAlign.justify,
                          );
                        } else if (snapshot.hasError) {
                          return _buildInfoText(
                            '${AppLocalizations.of(context).temperament}: $temperament',
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
                                  .translate(description, from: 'en', to: 'ru')
                                  .then((result) => result.text)
                              : Future.value(description),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return _buildInfoText(
                            '${AppLocalizations.of(context).description}: Загрузка...',
                            textAlign: TextAlign.justify,
                          );
                        } else if (snapshot.hasError) {
                          return _buildInfoText(
                            '${AppLocalizations.of(context).description}: $description',
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
                    SizedBox(height: 20),
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: EdgeInsets.symmetric(vertical: 8),
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
                            SizedBox(height: 10),
                            _buildCharacteristic(
                              AppLocalizations.of(context).energy,
                              energyLevel,
                            ),
                            _buildCharacteristic(
                              AppLocalizations.of(context).intelligence,
                              intelligence,
                            ),
                            _buildCharacteristic(
                              AppLocalizations.of(context).childFriendly,
                              childFriendly,
                            ),
                            _buildCharacteristic(
                              AppLocalizations.of(context).dogFriendly,
                              dogFriendly,
                            ),
                            _buildCharacteristic(
                              AppLocalizations.of(context).sheddingLevel,
                              sheddingLevel,
                            ),
                            SizedBox(height: 10),
                            _buildInfoText(
                              hypoallergenic
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
      style: TextStyle(
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
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Montserrat',
            ),
          ),
          Row(
            children: List.generate(
              level,
              (index) => Icon(Icons.star, color: Colors.amber, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
