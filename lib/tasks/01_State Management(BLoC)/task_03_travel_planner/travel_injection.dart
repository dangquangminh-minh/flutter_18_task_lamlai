import 'package:get_it/get_it.dart';

import 'data/datasources/travel_local_data_source.dart';
import 'data/datasources/travel_remote_data_source.dart';
import 'data/repositories/travel_repository.dart';
import 'network_info.dart';
import 'presentation/bloc/country/country_bloc.dart';
import 'presentation/bloc/favorite/favorite_cubit.dart';
import 'presentation/bloc/weather/weather_bloc.dart';


final sl=GetIt.instance;


Future<void> initTravelDI() async {
  if(!sl.isRegistered<TravelRemoteDataSource>()) {
    sl.registerLazySingleton<TravelRemoteDataSource>(
      ()=>TravelRemoteDataSource(),
    );
  }

  if(!sl.isRegistered<TravelLocalDataSource>()) {
    sl.registerLazySingleton<TravelLocalDataSource>(
      ()=>TravelLocalDataSource(),
    );
  }

  if(!sl.isRegistered<NetworkInfo>()) {
    sl.registerLazySingleton<NetworkInfo>(
      ()=>NetworkInfo(),
    );
  }

  if(!sl.isRegistered<TravelRepository>()) {
    sl.registerLazySingleton<TravelRepository>(
      ()=>TravelRepository(
        remote:sl<TravelRemoteDataSource>(),
        local:sl<TravelLocalDataSource>(),
        networkInfo:sl<NetworkInfo>(),
      ),
    );
  }

  if(!sl.isRegistered<CountryBloc>()) {
    sl.registerFactory<CountryBloc>(
      ()=>CountryBloc(sl<TravelRepository>()),
    );
  }

  if(!sl.isRegistered<WeatherBloc>()) {
    sl.registerFactory<WeatherBloc>(
      ()=>WeatherBloc(sl<TravelRepository>()),
    );
  }

  if(!sl.isRegistered<FavoriteCubit>()) {
    sl.registerFactory<FavoriteCubit>(
      ()=>FavoriteCubit(sl<TravelRepository>()),
    );
  }
}