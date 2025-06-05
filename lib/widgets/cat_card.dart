import 'package:flutter/material.dart';
import '../models/cat.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CatCard extends StatelessWidget {
  final Cat cat;
  final VoidCallback? onRemove;
  final VoidCallback? onTap;

  const CatCard({required this.cat, this.onRemove, this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: GestureDetector(
          onTap: onTap,
          child: SizedBox(
            width: 60,
            height: 60,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(cat.url, fit: BoxFit.cover),
            ),
          ),
        ),
        title: Text(
          cat.breedName,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          cat.likedAt != null
              ? '${l10n.likedCatsDatePrefix} ${cat.likedAt!.day.toString().padLeft(2, '0')}.${cat.likedAt!.month.toString().padLeft(2, '0')}.${cat.likedAt!.year}'
              : '',
          style: const TextStyle(fontFamily: 'Montserrat'),
        ),
        trailing:
            onRemove != null
                ? IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onRemove,
                )
                : null,
      ),
    );
  }
}
