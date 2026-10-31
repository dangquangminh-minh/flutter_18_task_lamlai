import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/travel_repository.dart';
import '../../../domain/models/country_model.dart';
import '../../../domain/models/weather_model.dart';

class FavoriteState {
  const FavoriteState({
    this.loading=false,
    this.syncing=false,
    this.favorites=const [],
    this.weatherByCode=const {},
    this.lastSync,
    this.message,
  });

  final bool loading;
  final bool syncing;
  final List<CountryModel> favorites;
  final Map<String, WeatherModel> weatherByCode;
  final DateTime? lastSync;
  final String? message;

  bool isFavorite(String code) {
    return favorites.any((e)=>e.code==code);
  }
}

// quản lý ds đã lưu vs cache thời tiết của từng nơi
class FavoriteCubit extends Cubit<FavoriteState> {
  FavoriteCubit(this._repository) : super(const FavoriteState());

  final TravelRepository _repository;

  // đọc lại favotite
  Future<void> load() async {
    emit(
      FavoriteState(
        loading:true,
        favorites:state.favorites,
        weatherByCode:state.weatherByCode,
      ),
    );

    final favorites=await _repository.getFavorites();
    final map=<String,WeatherModel>{};

    for(final country in favorites) {
      final weather=await _repository.getCachedWeather(country.code);

      if(weather!=null) {
        map[country.code]=weather;
      }
    }

    final lastSync=await _repository.getLastSync();

    emit(
      FavoriteState(
        favorites:favorites,
        weatherByCode:map,
        lastSync:lastSync,
      ),
    );
  }

  Future<void> toggle(CountryModel country) async {
    await _repository.toggleFavorite(country);
    await load();
  }

  // đồng bộ thòi tiết cho các nc yêu thích nếu còn internet 
  Future<void> sync() async {
    emit(
      FavoriteState(
        syncing:true,
        favorites:state.favorites,
        weatherByCode:state.weatherByCode,
        lastSync:state.lastSync,
      ),
    );

    try {
      await _repository.syncFavorites();
      await load();
    } catch(e) {
      emit(
        FavoriteState(
          favorites:state.favorites,
          weatherByCode:state.weatherByCode,
          lastSync:state.lastSync,
          message:e.toString(),
        ),
      );
    }
  }

  Future<void> clearCache() async {
    await _repository.clearCache();
    await load();
  }
}