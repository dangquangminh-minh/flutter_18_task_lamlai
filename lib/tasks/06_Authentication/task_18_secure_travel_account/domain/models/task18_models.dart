import 'package:firebase_auth/firebase_auth.dart';



class Task18Profile {
  const Task18Profile({
    required this.uid, required this.name, required this.email, required this.photoUrl,
    required this.cachedAt, });

  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final DateTime cachedAt;

  factory Task18Profile.fromFirebase( User user, ) {
    return Task18Profile( uid: user.uid, name: user.displayName ?.trim() .isNotEmpty == true
              ? user.displayName!.trim()
              : 'Khách du lịch',
      email: user.email ?? '', photoUrl: user.photoURL, cachedAt: DateTime.now(), );
  }

  factory Task18Profile.fromJson( Map<String, dynamic> json, ) {
    return Task18Profile( uid: json['uid']?.toString() ?? '', name: json['name']?.toString() ??
          'Khách du lịch',
      email: json['email']?.toString() ?? '', photoUrl: json['photoUrl']?.toString(), cachedAt:
          DateTime.tryParse( json['cachedAt'] ?.toString() ?? '', ) ??
          DateTime.fromMillisecondsSinceEpoch( 0, ), );
  }


  Map<String, dynamic> toJson() {
    return {
      'uid': uid, 'name': name, 'email': email, 'photoUrl': photoUrl, 'cachedAt':
          cachedAt.toIso8601String(), };
  }
}

// country

class Task18Country {
  const Task18Country({
    required this.code, required this.name, required this.capital, required this.region,
    required this.population, required this.flagUrl, required this.currencyCode,
    required this.currencySymbol, required this.callingCode, required this.timezone, });

  final String code;
  final String name;
  final String capital;
  final String region;
  final int population;
  final String flagUrl;
  final String currencyCode;
  final String currencySymbol;
  final String callingCode;
  final String timezone;

  factory Task18Country.fromApi( Map<String, dynamic> json, ) {


    final names = json['names'] is Map
            ? Map<String, dynamic>.from( json['names'] as Map, )
            : <String, dynamic>{};



    final codes = json['codes'] is Map
            ? Map<String, dynamic>.from( json['codes'] as Map, )
            : <String, dynamic>{};

    final flag = json['flag'] is Map
            ? Map<String, dynamic>.from( json['flag'] as Map, )
            : <String, dynamic>{};



    String capital = '';

    final capitalsRaw = json['capitals'];

    if (capitalsRaw is List) {
      for (final item in capitalsRaw) {
        if (item is Map) {
          final capitalMap = Map<String, dynamic>.from( item, );

          final value = capitalMap['name'] ?.toString() .trim();

          if (value != null && value.isNotEmpty) {
            capital = value;
            break;
          }
        } else if (item != null) {
          final value = item.toString().trim();

          if (value.isNotEmpty) {
            capital = value;
            break;
          }
        }
      }
    }

    // fallback nếu api trả capital[]
    if (capital.isEmpty) {
      final oldCapital = json['capital'];

      if (oldCapital is List && oldCapital.isNotEmpty) {
        capital = oldCapital.first .toString() .trim();
      } else if (oldCapital is String) {
        capital = oldCapital.trim();
      }
    }




    final currencies = json['currencies'] is Map
            ? Map<String, dynamic>.from( json['currencies'] as Map, )
            : <String, dynamic>{};

    String currencyCode = '';
    String currencySymbol = '';

    if (currencies.isNotEmpty) {
      currencyCode = currencies.keys.first;

      final rawCurrency = currencies[currencyCode];

      if (rawCurrency is Map) {
        final currency = Map<String, dynamic>.from( rawCurrency, );

        currencySymbol = currency['symbol'] ?.toString() ?? currencyCode;
      } else {
        currencySymbol = currencyCode;
      }
    }



    String callingCode = '';

    final callingRaw = json['calling_codes'];

    if (callingRaw is List && callingRaw.isNotEmpty) {
      final value = callingRaw.first .toString() .trim();

      if (value.isNotEmpty) {
        callingCode = value.startsWith('+')
                ? value
                : '+$value';
      }
    }


    if (callingCode.isEmpty && json['idd'] is Map) {
      final idd = Map<String, dynamic>.from( json['idd'] as Map, );

      final root = idd['root'] ?.toString() ?? '';

      final suffixes = idd['suffixes'] is List
              ? idd['suffixes'] as List
              : const [];

      if (root.isNotEmpty) {
        callingCode = suffixes.isNotEmpty
                ? '$root${suffixes.first}'
                : root;
      }
    }



    String timezone = '';

    final timezoneRaw = json['timezones'];

    if (timezoneRaw is List && timezoneRaw.isNotEmpty) {
      final first = timezoneRaw.first;

      if (first is Map) {
        timezone = first['name'] ?.toString() ?? first['utc_offset'] ?.toString() ?? '';
      } else {
        timezone = first.toString();
      }
    }



    final oldName = json['name'] is Map
            ? Map<String, dynamic>.from( json['name'] as Map, )
            : <String, dynamic>{};

    final oldFlags = json['flags'] is Map
            ? Map<String, dynamic>.from( json['flags'] as Map, )
            : <String, dynamic>{};

    return Task18Country( code: codes['alpha_2'] ?.toString() ?? json['cca2'] ?.toString() ?? '', name:
          names['common'] ?.toString() ?? oldName['common'] ?.toString() ?? '',
      capital: capital, region: json['region'] ?.toString() ?? '', population:
          (json['population'] as num?) ?.toInt() ?? 0,
      flagUrl: flag['url_png'] ?.toString() ?? oldFlags['png'] ?.toString() ?? '', currencyCode:
          currencyCode,
      currencySymbol: currencySymbol, callingCode: callingCode, timezone: timezone, );
  }

  factory Task18Country.fromCache( Map<String, dynamic> json, ) {
    return Task18Country( code: json['code']?.toString() ?? '', name: json['name']?.toString() ?? '',
      capital: json['capital']?.toString() ?? '', region: json['region']?.toString() ?? '', population:
          (json['population'] as num?) ?.toInt() ?? 0,
      flagUrl: json['flagUrl']?.toString() ?? '', currencyCode: json['currencyCode'] ?.toString() ?? '',
      currencySymbol: json['currencySymbol'] ?.toString() ?? '', callingCode: json['callingCode']
                  ?.toString() ??
              '',
      timezone: json['timezone'] ?.toString() ?? '', );
  }


  Map<String, dynamic> toJson() {
    return {
      'code': code, 'name': name, 'capital': capital, 'region': region, 'population': population,
      'flagUrl': flagUrl, 'currencyCode': currencyCode, 'currencySymbol': currencySymbol,
      'callingCode': callingCode, 'timezone': timezone, };
  }
}






// weather
class Task18Weather {
  const Task18Weather({
    required this.city, required this.temperatureC, required this.description, required this.humidity,
    required this.windKmh, required this.iconCode, required this.fetchedAt, });

  final String city;
  final double temperatureC;
  final String description;
  final int humidity;
  final double windKmh;
  final String iconCode;
  final DateTime fetchedAt;

  String get iconUrl {
    if (iconCode.isEmpty) {
      return '';
    }

    return 'https://openweathermap.org/'
        'img/wn/$iconCode@2x.png';
  }

  factory Task18Weather.fromApi( Map<String, dynamic> json, ) {
    final main = json['main'] is Map
            ? Map<String, dynamic>.from( json['main'] as Map, )
            : <String, dynamic>{};

    final wind = json['wind'] is Map
            ? Map<String, dynamic>.from( json['wind'] as Map, )
            : <String, dynamic>{};

    final weatherList = json['weather'] is List
            ? json['weather'] as List
            : const [];

    Map<String, dynamic> weather = <String, dynamic>{};

    if (weatherList.isNotEmpty && weatherList.first is Map) {
      weather = Map<String, dynamic>.from( weatherList.first as Map, );
    }

    return Task18Weather( city: json['name']?.toString() ?? '', temperatureC: (main['temp'] as num?)
                  ?.toDouble() ??
              0,
      description: weather['description'] ?.toString() ?? '', humidity: (main['humidity'] as num?)
                  ?.toInt() ??
              0,
      windKmh: ((wind['speed'] as num?) ?.toDouble() ?? 0) *
              3.6,
      iconCode: weather['icon'] ?.toString() ?? '', fetchedAt: DateTime.now(), );
  }

  factory Task18Weather.fromCache( Map<String, dynamic> json, ) {
    return Task18Weather( city: json['city']?.toString() ?? '', temperatureC:
          (json['temperatureC'] as num?) ?.toDouble() ?? 0,
      description: json['description'] ?.toString() ?? '', humidity: (json['humidity'] as num?)
                  ?.toInt() ??
              0,
      windKmh: (json['windKmh'] as num?) ?.toDouble() ?? 0, iconCode: json['iconCode'] ?.toString() ??
              '',
      fetchedAt: DateTime.tryParse( json['fetchedAt'] ?.toString() ?? '', ) ??
          DateTime.fromMillisecondsSinceEpoch( 0, ), );
  }

  
  Map<String, dynamic> toJson() {
    return {
      'city': city, 'temperatureC': temperatureC, 'description': description, 'humidity': humidity,
      'windKmh': windKmh, 'iconCode': iconCode, 'fetchedAt': fetchedAt.toIso8601String(), };
  }
}

// snapshot
class Task18TravelSnapshot {
  const Task18TravelSnapshot({
    required this.profile, required this.country, required this.weather, required this.updatedAt, });

  final Task18Profile profile;
  final Task18Country country;
  final Task18Weather weather;
  final DateTime updatedAt;

  bool get isStale {
    return DateTime.now() .difference(updatedAt) > const Duration(hours: 24);
  }
}
