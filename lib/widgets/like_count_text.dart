import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LikeCountText extends StatelessWidget {
  final int likeCount;

  const LikeCountText({required this.likeCount, super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      '${AppLocalizations.of(context).likesCount}$likeCount',
      style: const TextStyle(fontSize: 18, fontFamily: 'Montserrat'),
    );
  }
}
