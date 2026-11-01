

class TravelCountry {
  const TravelCountry({
    required this.name, // tên thường dùng

    required this.officialName,// tên chính thức

    required this.cca2, // để p.bt qg

    required this.capital,
    required this.region,
    required this.subregion,

    required this.population,
    required this.flagUrl,

    required this.currency,
    required this.languages,
    required this.timezone,

//tọa độ 
    required this.latitude,
    required this.longitude,
  });

  final String name;
  final String officialName;
  final String cca2;
  final String capital;
  final String region;
  final String subregion;
  final int population;
  final String flagUrl;
  final String currency;
  final String languages;
  final String timezone;

  final double latitude;
  final double longitude;




  factory TravelCountry.fromJson(
    Map<String, dynamic> json,
  ) {

    final names = Map<String, dynamic>.from(
      json['names'] ?? {},
    );


    final codes = Map<String, dynamic>.from(
      json['codes'] ?? {},
    );



    final flag = Map<String, dynamic>.from(
      json['flag'] ?? {},
    );


    final coordinates = Map<String, dynamic>.from(
      json['coordinates'] ?? {},
    );

  

    String capital = 'Không rõ';

    final capitals = json['capitals'];

    if (capitals is List && capitals.isNotEmpty) {
      final first = capitals.first;

      if (first is Map) {
        final capitalMap = Map<String, dynamic>.from(first);

        capital =
            capitalMap['name']?.toString() ?? 'Không rõ';
      } else {
        capital = first.toString();
      }
    }


    String currencyText = 'Không rõ';

    final currenciesRaw = json['currencies'];

    if (currenciesRaw is Map &&
        currenciesRaw.isNotEmpty) {
      final currencies =
          Map<String, dynamic>.from(currenciesRaw);

      final code = currencies.keys.first;
      final value = currencies[code];

      if (value is Map) {
        final currency =
            Map<String, dynamic>.from(value);

        final symbol =
            currency['symbol']?.toString() ?? '';

        currencyText = symbol.isEmpty
            ? code
            : '$code ($symbol)';
      } else {
        currencyText = code;
      }
    }


    String languageText = 'Không rõ';

    final languagesRaw = json['languages'];


    // restcountries v5
    if (languagesRaw is List) {
      final result = <String>[];

      for (final item in languagesRaw) {
        if (item is Map) {
          final language =
              Map<String, dynamic>.from(item);

          final name =
              language['name']?.toString() ??
              language['english_name']?.toString() ??
              language['native_name']?.toString();

          if (name != null && name.isNotEmpty) {
            result.add(name);
          }
        } else if (item != null) {
          result.add(item.toString());
        }
      }

      if (result.isNotEmpty) {
        languageText = result.join(', ');
      }
    }

    // fallback if api trả kiểu map
    else if (languagesRaw is Map) {
      final languages =
          Map<String, dynamic>.from(languagesRaw);

      if (languages.isNotEmpty) {
        languageText = languages.values
            .map((e) => e.toString())
            .join(', ');
      }
    }



    final timezones =
        json['timezones'] as List? ?? [];

    return TravelCountry(
      name:
          names['common']?.toString() ?? 'Unknown',

      officialName:
          names['official']?.toString() ?? '',

      cca2:
          codes['alpha_2']?.toString() ?? '',

      capital: capital,

      region:
          json['region']?.toString() ?? '',

      subregion:
          json['subregion']?.toString() ?? '',

      population:
          (json['population'] as num?)?.toInt() ?? 0,

      flagUrl:
          flag['url_png']?.toString() ??
          flag['url_svg']?.toString() ??
          '',

      currency: currencyText,

      languages: languageText,

      timezone: timezones.isNotEmpty
          ? timezones.first.toString()
          : 'Không rõ',

      latitude:
          (coordinates['lat'] as num?)?.toDouble() ?? 0,

      longitude:
          (coordinates['lng'] as num?)?.toDouble() ?? 0,
    );
  }

  factory TravelCountry.fromMap(
    Map<String, dynamic> map,
  ) {
    return TravelCountry(
      name: map['name'] ?? '',
      officialName: map['officialName'] ?? '',
      cca2: map['cca2'] ?? '',
      capital: map['capital'] ?? '',
      region: map['region'] ?? '',
      subregion: map['subregion'] ?? '',
      population: map['population'] ?? 0,
      flagUrl: map['flagUrl'] ?? '',
      currency: map['currency'] ?? '',
      languages: map['languages'] ?? '',
      timezone: map['timezone'] ?? '',

      latitude:
          (map['latitude'] as num?)?.toDouble() ?? 0,
      longitude:
          (map['longitude'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'officialName': officialName,
      'cca2': cca2,
      'capital': capital,
      'region': region,
      'subregion': subregion,
      'population': population,
      'flagUrl': flagUrl,
      'currency': currency,
      'languages': languages,
      'timezone': timezone,
      
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}