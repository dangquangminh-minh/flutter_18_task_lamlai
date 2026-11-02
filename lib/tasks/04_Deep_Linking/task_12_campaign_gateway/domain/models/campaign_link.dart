

class CampaignLink {
  const CampaignLink({
    required this.id,
    required this.source,
    this.exp,
    this.sig,
  });

  final int id;
  final String source;

  final int? exp;
  final String? sig;



  bool get isSigned =>
      exp != null && sig != null;

  Map<String, String> get queryParameters {
    return {
      'source': source,
      if (exp != null)
        'exp': exp.toString(),
      'sig': ?sig,
    };
  }



  String get appUri {
    return Uri(
      scheme: 'myapp',
      host: 'campaign',
      path: '/$id',
      queryParameters: queryParameters,
    ).toString();
  }

  String get route {
    return Uri(
      path: '/campaign/$id',
      queryParameters: queryParameters,
    ).toString();
  }
}