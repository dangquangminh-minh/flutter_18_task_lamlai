abstract class CountryEvent {
  const CountryEvent();
}

class CountryStarted
    extends CountryEvent {
  const CountryStarted();
}

class CountrySearchRequested
    extends CountryEvent {
  const CountrySearchRequested(
    
    this.query,
  );

  final String query;
}

class CountryRetryRequested
    extends CountryEvent {
  const CountryRetryRequested();
}