import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/liked_cats_cubit.dart';
import '../di/di.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../widgets/animated_remove_cat_card.dart';

class LikedCatsScreen extends StatelessWidget {
  const LikedCatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocProvider.value(
      value: sl<LikedCatsCubit>(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            l10n.likedCatsTitle,
            style: const TextStyle(fontFamily: 'Montserrat'),
          ),
        ),
        body: Column(
          children: [
            _BreedFilterDropdown(),
            Expanded(
              child: BlocBuilder<LikedCatsCubit, LikedCatsState>(
                builder: (context, state) {
                  final cats = state.filteredCats;
                  if (cats.isEmpty) {
                    return Center(child: Text(l10n.likedCatsNoCats));
                  }
                  return ListView.builder(
                    itemCount: cats.length,
                    itemBuilder: (context, index) {
                      final cat = cats[index];
                      return AnimatedRemoveCatCard(
                        key: ValueKey(cat.url),
                        cat: cat,
                        onRemove:
                            () => context.read<LikedCatsCubit>().removeCat(cat),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/details',
                            arguments: cat,
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BreedFilterDropdown extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<LikedCatsCubit, LikedCatsState>(
      builder: (context, state) {
        final breeds = state.cats.map((e) => e.breedName).toSet().toList();
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: DropdownButton<String>(
            hint: Text(l10n.likedCatsBreedFilter),
            value: state.breedFilter.isEmpty ? null : state.breedFilter,
            items: [
              DropdownMenuItem(value: '', child: Text(l10n.likedCatsAll)),
              ...breeds.map((b) => DropdownMenuItem(value: b, child: Text(b))),
            ],
            onChanged: (v) {
              if (v == null || v.isEmpty) {
                context.read<LikedCatsCubit>().resetFilter();
              } else {
                context.read<LikedCatsCubit>().filterByBreed(v);
              }
            },
          ),
        );
      },
    );
  }
}
