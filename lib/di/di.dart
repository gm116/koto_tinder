import 'package:get_it/get_it.dart';
import '../cubit/liked_cats_cubit.dart';

final sl = GetIt.instance;

void initDI() {
  sl.registerSingleton<LikedCatsCubit>(LikedCatsCubit());
}
