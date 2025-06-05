import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../cubit/liked_cats_cubit.dart';
import '../di/di.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
                      return Dismissible(
                        key: ValueKey(cat.url),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) =>
                            context.read<LikedCatsCubit>().removeCat(cat),
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: ListTile(
                          leading: cat.url.isNotEmpty
                              ? CachedNetworkImage(
                            imageUrl: cat.url,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey,
                              child: const Icon(Icons.broken_image, color: Colors.white),
                            ),
                          )
                              : null,
                          title: Text(cat.breedName),
                          subtitle: Text(cat.origin),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/details',
                              arguments: cat,
                            );
                          },
                        ),
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