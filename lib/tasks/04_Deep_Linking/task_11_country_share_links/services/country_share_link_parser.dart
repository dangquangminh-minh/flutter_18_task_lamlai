

enum CountryShareLinkKind {
  countries,
  country,
  invalid,
}

class CountryShareLinkResult {
  const CountryShareLinkResult({
    required this.kind,
    this.region,
    this.code,
    this.name,
    this.message,
  });

  final CountryShareLinkKind kind;
  final String? region;
  final String? code;
  final String? name;
  final String? message;
}

class CountryShareLinkParser {
  const CountryShareLinkParser._();

  static const Map<String,String> regions={
    'africa':'Africa',
    'americas':'Americas',
    'asia':'Asia',
    'europe':'Europe',
    'oceania':'Oceania',
  };

  // chỉ nhận 5 khu vực được api sd

  static String? normalizeRegion(String? value) {
    if(value==null || value.trim().isEmpty) return null;
    return regions[value.trim().toLowerCase()];
  }

  // mã iso alpha-3 phải đúng 3 chữ cái, k cho mã dài vs ngắn khác

  static bool isValidCode(String value) {
    return RegExp(r'^[A-Za-z]{3}$').hasMatch(value.trim());
  }

  static CountryShareLinkResult parseUri(Uri uri) {
    if(uri.scheme.toLowerCase()!='myapp') {
      return const CountryShareLinkResult(
        kind:CountryShareLinkKind.invalid,
        message:'Scheme không hợp lệ.',
      );
    }

    final host=uri.host.toLowerCase();



    // myapp://countries?region=Asia
    if(host=='countries') {
      if(uri.pathSegments.isNotEmpty) {
        return const CountryShareLinkResult(
          kind:CountryShareLinkKind.invalid,
          message:'Đường dẫn countries không hợp lệ.',
        );
      }

      final rawRegion=uri.queryParameters['region'];

      if(rawRegion==null || rawRegion.trim().isEmpty) {
        return const CountryShareLinkResult(
          kind:CountryShareLinkKind.countries,
        );
      }

      final region=normalizeRegion(rawRegion);

      if(region==null) {
        return CountryShareLinkResult(
          kind:CountryShareLinkKind.invalid,
          message:'Khu vực "$rawRegion" không hợp lệ.',
        );
      }

      return CountryShareLinkResult(
        kind:CountryShareLinkKind.countries,
        region:region,
      );
    }

    // myapp://country/VNM
    if(host=='country') {
      if(uri.pathSegments.length!=1) {
        return const CountryShareLinkResult(
          kind:CountryShareLinkKind.invalid,
          message:'Đường dẫn quốc gia không hợp lệ.',
        );
      }

      final code=uri.pathSegments.first;

      if(!isValidCode(code)) {
        return CountryShareLinkResult(
          kind:CountryShareLinkKind.invalid,
          message:'Mã quốc gia phải gồm đúng 3 ký tự chữ cái.',
        );
      }

      return CountryShareLinkResult(
        kind:CountryShareLinkKind.country,
        code:code.toUpperCase(),
      );
    }

    // myapp://country-name/Abkhazia
    if(host=='country-name') {
      if(uri.pathSegments.length!=1) {
        return const CountryShareLinkResult(
          kind:CountryShareLinkKind.invalid,
          message:'Đường dẫn tên quốc gia không hợp lệ.',
        );
      }

      final name=Uri.decodeComponent(uri.pathSegments.first).trim();

      if(name.isEmpty) {
        return const CountryShareLinkResult(
          kind:CountryShareLinkKind.invalid,
          message:'Tên quốc gia không được để trống.',
        );
      }

      return CountryShareLinkResult(
        kind:CountryShareLinkKind.country,
        name:name,
      );
    }

    return const CountryShareLinkResult(
      kind:CountryShareLinkKind.invalid,
      message:'Deep Link không thuộc Country Share.',
    );
  }


  static String buildListLink(String? region) {
    if(region==null || region.trim().isEmpty) {
      return 'myapp://countries';
    }

    return Uri(
      scheme:'myapp',
      host:'countries',
      queryParameters:{'region':region},
    ).toString();
  }

  static String buildCountryLink({
    required String code,
    required String name,
  }) {
    final normalized=code.trim().toUpperCase();

    if(isValidCode(normalized)) {
      return 'myapp://country/$normalized';
    }

    return Uri(
      scheme:'myapp',
      host:'country-name',
      pathSegments:[name.trim()],
    ).toString();
  }
}