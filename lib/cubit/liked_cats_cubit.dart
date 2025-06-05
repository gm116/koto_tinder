import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cat.dart';

class LikedCatsState {
  final List<Cat> cats;
  final String breedFilter;

  LikedCatsState({required this.cats, this.breedFilter = ''});

  List<Cat> get filteredCats =>
      breedFilter.isEmpty
          ? cats
          : cats.where((cat) => cat.breedName == breedFilter).toList();

  LikedCatsState copyWith({List<Cat>? cats, String? breedFilter}) {
    return LikedCatsState(
      cats: cats ?? this.cats,
      breedFilter: breedFilter ?? this.breedFilter,
    );
  }
}

class LikedCatsCubit extends Cubit<LikedCatsState> {
  static const String likedCatsKey = 'liked_cats';

  LikedCatsCubit() : super(LikedCatsState(cats: [])) {
    _loadLikedCats();
  }

  Future<void> _loadLikedCats() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(likedCatsKey);
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      final cats = jsonList.map((json) => Cat.fromMap(json)).toList();
      emit(state.copyWith(cats: cats));
    }
  }

  Future<void> likeCat(Cat cat) async {
    if (!state.cats.any((c) => c.url == cat.url)) {
      final updated = List<Cat>.from(state.cats)
        ..add(cat.copyWith(likedAt: DateTime.now()));
      emit(state.copyWith(cats: updated));
      await _saveLikedCats(updated);
    }
  }

  Future<void> removeCat(Cat cat) async {
    final updated = List<Cat>.from(state.cats)
      ..removeWhere((c) => c.url == cat.url);
    emit(state.copyWith(cats: updated));
    await _saveLikedCats(updated);
  }

  Future<void> _saveLikedCats(List<Cat> cats) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(cats.map((c) => c.toMap()).toList());
    await prefs.setString(likedCatsKey, jsonString);
  }

  void filterByBreed(String breed) {
    emit(state.copyWith(breedFilter: breed));
  }

  void resetFilter() {
    emit(state.copyWith(breedFilter: ''));
  }
}
