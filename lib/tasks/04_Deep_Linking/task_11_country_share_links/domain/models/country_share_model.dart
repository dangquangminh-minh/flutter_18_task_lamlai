

class CountryShareModel {
  const CountryShareModel({
    required this.name,
    required this.officialName,

    required this.cca2, // mã qg iso 2 chữ
    required this.cca3, // 3 chữ

    required this.capital,
    required this.region,
    required this.subregion,
    required this.population,
    required this.flagUrl,
    required this.flagEmoji,
    required this.areaKm2,
    required this.currency,
    required this.currencySymbol,

    required this.languages,
    required this.timezone,
    required this.callingCode, // mã đth quốc tế
    required this.tld,  // đuôi tên miền

    required this.latitude, // vĩ độ 
    required this.longitude, // kinh độ
  });

  final String name;
  final String officialName;
  final String cca2;
  final String cca3;
  final String capital;
  final String region;
  final String subregion;
  final int population;
  final String flagUrl;
  final String flagEmoji;
  final double areaKm2;
  final String currency;
  final String currencySymbol;
  final String languages;
  final String timezone;
  final String callingCode;
  final String tld;
  final double latitude;
  final double longitude;


  factory CountryShareModel.fromJson(
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

    final area = Map<String, dynamic>.from(
      json['area'] ?? {},
    );

    final coordinates = Map<String, dynamic>.from(
      json['coordinates'] ?? {},
    );

    // Capital
    String capital = 'Không rõ';

    // 1 qg có thể k có thủ đô hoặc có nhiều thủ đô, ui lấy giá trị đầu tiên

    final capitals = json['capitals'];

    if (capitals is List && capitals.isNotEmpty) {
      final first = capitals.first;

      if (first is Map) {
        final map = Map<String, dynamic>.from(first);
        capital =
            map['name']?.toString() ?? 'Không rõ';
      } else {
        capital = first.toString();
      }
    }

    // Currency
    String currency = 'Không rõ';
    String currencySymbol = '';

    

    final currencies = json['currencies'];

    // Schema v5
    if (currencies is List && currencies.isNotEmpty) {
      final first = currencies.first;

      if (first is Map) {
        final map = Map<String, dynamic>.from(first);

        final code =
            map['code']?.toString() ?? '';

        final name =
            map['name']?.toString() ?? '';

        currencySymbol =
            map['symbol']?.toString() ?? '';

        if (name.isNotEmpty && code.isNotEmpty) {
          currency = '$name ($code)';
        } else if (code.isNotEmpty) {
          currency = code;
        }
      }
    }


    else if (currencies is Map &&
        currencies.isNotEmpty) {
      final map =
          Map<String, dynamic>.from(currencies);

      final code = map.keys.first;
      final value = map[code];

      if (value is Map) {
        final detail =
            Map<String, dynamic>.from(value);

        final name =
            detail['name']?.toString() ?? '';

        currencySymbol =
            detail['symbol']?.toString() ?? '';

        currency = name.isEmpty
            ? code
            : '$name ($code)';
      }
    }

    // languages
    String languagesText = 'Không rõ';

    final languages = json['languages'];

    if (languages is List) {
      final result = <String>[];

      for (final item in languages) {
        if (item is Map) {
          final map =
              Map<String, dynamic>.from(item);

          final name =
              map['name']?.toString() ??
              map['english_name']?.toString();

          if (name != null && name.isNotEmpty) {
            result.add(name);
          }
        }
      }

      if (result.isNotEmpty) {
        languagesText = result.join(', ');
      }
    }

    final timezones =
        json['timezones'] as List? ?? [];

    final callingCodes =
        json['calling_codes'] as List? ?? [];

    final tlds =
        json['tlds'] as List? ?? [];

    final png=flag['url_png']?.toString().trim() ?? '';
    final svg=flag['url_svg']?.toString().trim() ?? '';
    final emoji=flag['emoji']?.toString().trim() ?? '';

    // chọn png trc,if thiếu thì dùng svg hoặc icon emoji thay thế

    final flagUrl=png.isNotEmpty
        ? png
        : svg.isNotEmpty
            ? svg
            : '';

    final flagEmoji=emoji.isNotEmpty ? emoji : '🏳️';
    return CountryShareModel(
      name:
          names['common']?.toString() ?? 'Unknown',
      officialName:
          names['official']?.toString() ?? '',
      cca2:
          codes['alpha_2']?.toString() ?? '',
      cca3:
          codes['alpha_3']?.toString() ?? '',
      capital: capital,
      region:
          json['region']?.toString() ?? '',
      subregion:
          json['subregion']?.toString() ?? '',
      population:
          (json['population'] as num?)?.toInt() ?? 0,
      flagUrl:flagUrl,
      flagEmoji:flagEmoji,
      areaKm2:
          (area['kilometers'] as num?)?.toDouble() ??
          0,
      currency: currency,
      currencySymbol: currencySymbol,
      languages: languagesText,
      timezone: timezones.isNotEmpty
          ? timezones.first.toString()
          : 'Không rõ',
      callingCode: callingCodes.isNotEmpty
          ? '+${callingCodes.first}'
          : 'Không rõ',
      tld: tlds.isNotEmpty
          ? tlds.first.toString()
          : 'Không rõ',
      latitude:
          (coordinates['lat'] as num?)?.toDouble() ??
          0,
      longitude:
          (coordinates['lng'] as num?)?.toDouble() ??
          0,
    );
  }
}