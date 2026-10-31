class CountryModel {
  const CountryModel({
    required this.name,
    required this.officialName,
    required this.code,
    required this.capital,
    required this.region,
    required this.subregion,
    required this.population,
    required this.flagUrl,
    required this.currencyCode,
    required this.currencyName,
    required this.currencySymbol,
    required this.language,
    required this.timezone,
    required this.latitude,
    required this.longitude,
  });

  final String name;
  final String officialName;
  final String code;
  final String capital;
  final String region;
  final String subregion;
  final int population;
  final String flagUrl;
  final String currencyCode;
  final String currencyName;
  final String currencySymbol;
  final String language;
  final String timezone;
  final double latitude;
  final double longitude;

  factory CountryModel.fromV3(Map<String,dynamic> json) {
    final name=_map(json['name']);
    final flags=_map(json['flags']);
    final currencies=_map(json['currencies']);
    final languages=_map(json['languages']);
    final capitals=_list(json['capital']);
    final timezones=_list(json['timezones']);
    final latlng=_list(json['latlng']);

    String currencyCode='';
    String currencyName='';
    String currencySymbol='';

    if(currencies.isNotEmpty) {
      currencyCode=currencies.keys.first;
      final currency=_map(currencies[currencyCode]);
      currencyName=currency['name']?.toString() ?? '';
      currencySymbol=currency['symbol']?.toString() ?? '';
    }

    return CountryModel(
      name:name['common']?.toString() ?? '',
      officialName:name['official']?.toString() ?? '',
      code:json['cca2']?.toString() ?? '',
      capital:capitals.isNotEmpty ? capitals.first.toString() : '',
      region:json['region']?.toString() ?? '',
      subregion:json['subregion']?.toString() ?? '',
      population:(json['population'] as num?)?.toInt() ?? 0,
      flagUrl:flags['png']?.toString() ?? '',
      currencyCode:currencyCode,
      currencyName:currencyName,
      currencySymbol:currencySymbol,
      language:languages.isNotEmpty ? languages.values.first.toString() : '',
      timezone:timezones.isNotEmpty ? timezones.first.toString() : '',
      latitude:latlng.isNotEmpty ? (latlng[0] as num?)?.toDouble() ?? 0 : 0,
      longitude:latlng.length>1 ? (latlng[1] as num?)?.toDouble() ?? 0 : 0,
    );
  }

  factory CountryModel.fromV5(Map<String,dynamic> json) {
    final names=_map(json['names']);
    final codes=_map(json['codes']);
    final flag=_map(json['flag']);
    final capitals=_list(json['capitals']);
    final timezones=_list(json['timezones']);
    final coordinates=_map(json['coordinates']);

    String capital='';
    if(capitals.isNotEmpty) {
      final first=capitals.first;
      capital=first is Map ? first['name']?.toString() ?? '' : first.toString();
    }

    String currencyCode='';
    String currencyName='';
    String currencySymbol='';
    final currencies=json['currencies'];

    if(currencies is Map && currencies.isNotEmpty) {
      final map=Map<String,dynamic>.from(currencies);
      currencyCode=map.keys.first;
      final currency=_map(map[currencyCode]);
      currencyName=currency['name']?.toString() ?? '';
      currencySymbol=currency['symbol']?.toString() ?? '';
    } else if(currencies is List && currencies.isNotEmpty) {
      final currency=_map(currencies.first);
      currencyCode=currency['code']?.toString() ?? '';
      currencyName=currency['name']?.toString() ?? '';
      currencySymbol=currency['symbol']?.toString() ?? '';
    }

    String language='';
    final languages=json['languages'];

    if(languages is List && languages.isNotEmpty) {
      final first=languages.first;
      language=first is Map
          ? (first['name'] ?? first['english_name'] ?? '').toString()
          : first.toString();
    } else if(languages is Map && languages.isNotEmpty) {
      language=languages.values.first.toString();
    }

    return CountryModel(
      name:names['common']?.toString() ?? '',
      officialName:names['official']?.toString() ?? '',
      code:codes['alpha_2']?.toString() ?? '',
      capital:capital,
      region:json['region']?.toString() ?? '',
      subregion:json['subregion']?.toString() ?? '',
      population:(json['population'] as num?)?.toInt() ?? 0,
      flagUrl:flag['url_png']?.toString() ?? '',
      currencyCode:currencyCode,
      currencyName:currencyName,
      currencySymbol:currencySymbol,
      language:language,
      timezone:timezones.isNotEmpty ? timezones.first.toString() : '',
      latitude:(coordinates['lat'] as num?)?.toDouble() ?? 0,
      longitude:(coordinates['lng'] as num?)?.toDouble() ?? 0,
    );
  }

  factory CountryModel.fromJson(Map<String,dynamic> json) {
    return CountryModel(
      name:json['name']?.toString() ?? '',
      officialName:json['officialName']?.toString() ?? '',
      code:json['code']?.toString() ?? '',
      capital:json['capital']?.toString() ?? '',
      region:json['region']?.toString() ?? '',
      subregion:json['subregion']?.toString() ?? '',
      population:(json['population'] as num?)?.toInt() ?? 0,
      flagUrl:json['flagUrl']?.toString() ?? '',
      currencyCode:json['currencyCode']?.toString() ?? '',
      currencyName:json['currencyName']?.toString() ?? '',
      currencySymbol:json['currencySymbol']?.toString() ?? '',
      language:json['language']?.toString() ?? '',
      timezone:json['timezone']?.toString() ?? '',
      latitude:(json['latitude'] as num?)?.toDouble() ?? 0,
      longitude:(json['longitude'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String,dynamic> toJson()=>{
    'name':name,
    'officialName':officialName,
    'code':code,
    'capital':capital,
    'region':region,
    'subregion':subregion,
    'population':population,
    'flagUrl':flagUrl,
    'currencyCode':currencyCode,
    'currencyName':currencyName,
    'currencySymbol':currencySymbol,
    'language':language,
    'timezone':timezone,
    'latitude':latitude,
    'longitude':longitude,
  };

  static Map<String,dynamic> _map(dynamic value) {
    return value is Map ? Map<String,dynamic>.from(value) : <String,dynamic>{};
  }

  static List<dynamic> _list(dynamic value) {
    return value is List ? value : const [];
  }
}