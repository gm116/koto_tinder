import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/cat.dart';

class LikedCatsState {
  final List<Cat> cats;
  final String breedFilter;

  LikedCatsState({required this.cats, this.breedFilter = ''});

  List<Cat> get filteredCats {
    if (breedFilter.isEmpty) return cats;
    return cats.where((cat) => cat.breedName == breedFilter).toList();
  }

  LikedCatsState copyWith({List<Cat>? cats, String? breedFilter}) {
    return LikedCatsState(
      cats: cats ?? this.cats,
      breedFilter: breedFilter ?? this.breedFilter,
    );
  }
}

class LikedCatsCubit extends Cubit<LikedCatsState> {
  LikedCatsCubit() : super(LikedCatsState(cats: []));

  void likeCat(Cat cat) {
    final likedCat = cat.copyWith(likedAt: DateTime.now());
    emit(state.copyWith(cats: [likedCat, ...state.cats]));
  }

  void removeCat(Cat cat) {
    final updated = List<Cat>.from(state.cats)
      ..removeWhere((c) => c.url == cat.url);
    emit(state.copyWith(cats: updated));
  }

  void filterByBreed(String breed) {
    emit(state.copyWith(breedFilter: breed));
  }

  void resetFilter() {
    emit(state.copyWith(breedFilter: ''));
  }
}
