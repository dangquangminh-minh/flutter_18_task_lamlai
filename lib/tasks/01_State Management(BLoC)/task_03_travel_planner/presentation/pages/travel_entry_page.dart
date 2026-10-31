import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../travel_injection.dart';
import '../bloc/country/country_bloc.dart';
import '../bloc/favorite/favorite_cubit.dart';
import '../bloc/weather/weather_bloc.dart';
import '../travel_theme.dart';
import 'travel_main_page.dart';


Future<void>? _travelReady;

Future<void> _prepareTravel() {
  return _travelReady ??= _initializeTravel();
}

Future<void> _initializeTravel() async {
  try {
    await Hive.initFlutter();
    await initTravelDI();
  } catch (_) {

    _travelReady = null;
    rethrow;
  }
}



class TravelEntryPage extends StatefulWidget {
  const TravelEntryPage({super.key});

  @override
  State<TravelEntryPage> createState() => _TravelEntryPageState();
}

class _TravelEntryPageState extends State<TravelEntryPage> {
  late Future<void> _loading;

  @override
  void initState() {
    super.initState();
    _loading = _prepareTravel();
  }

  void _retry() {
    setState(() => _loading = _prepareTravel());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loading,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            backgroundColor: travelBackground,
            body: Center(child: CircularProgressIndicator(color: travelPrimary)),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: travelBackground,
            appBar: AppBar(title: const Text('Travel Planner Pro')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.storage_rounded, size: 44, color: travelPrimary),
                    const SizedBox(height: 12),
                    const Text('Không khởi tạo được dữ liệu offline'),
                    const SizedBox(height: 8),
                    Text('${snapshot.error}', textAlign: TextAlign.center),
                    const SizedBox(height: 14),
                    FilledButton(onPressed: _retry, child: const Text('Thử lại')),
                  ],
                ),
              ),
            ),
          );
        }


        return MultiBlocProvider(
          providers: [
            BlocProvider<CountryBloc>(create: (_) => sl<CountryBloc>()),
            BlocProvider<WeatherBloc>(create: (_) => sl<WeatherBloc>()),
            BlocProvider<FavoriteCubit>(create: (_) => sl<FavoriteCubit>()),
          ],
          child: const TravelMainPage(),
        );
      },
    );
  }
}
