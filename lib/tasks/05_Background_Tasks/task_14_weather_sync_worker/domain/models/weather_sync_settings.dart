
class WeatherCity {
  const WeatherCity({
    required this.key,
    required this.label,
    required this.query,
  });

  final String key;
  final String label;
  final String query;

  static const hoChiMinh = WeatherCity(
    key: 'hcm',
    label: 'TP. Hồ Chí Minh',
    query: 'Ho Chi Minh',
  );

  static const haNoi = WeatherCity(
    key: 'hanoi',
    label: 'Hà Nội',
    query: 'Ha Noi',
  );

  static const daNang = WeatherCity(
    key: 'danang',
    label: 'Đà Nẵng',
    query: 'Da Nang',
  );

  // chọn tp trên ui
  static const all = [
    hoChiMinh,
    haNoi,
    daNang,
  ];

  // tìm thành phố theo mã đã lưu
  static WeatherCity byKey(String key) {
    for (final city in all) {
      if (city.key == key) {
        return city;
      }
    }

    return hoChiMinh;
  }
}

// cài đặt chu kỳ
class WeatherSyncSettings {
  const WeatherSyncSettings({
    required this.cityKey,
    required this.intervalMinutes,
    required this.wifiOnly,
    required this.chargingOnly,

    required this.batteryNotLow,

    required this.alertEnabled,
    required this.thresholdC,

    required this.workerEnabled,
  });

  final String cityKey;
  final int intervalMinutes;

  final bool wifiOnly;
  final bool chargingOnly;
  final bool batteryNotLow;

  final bool alertEnabled;
  final double thresholdC;

  final bool workerEnabled;

  // trả về c.hình lần đầu, tránh worker nhận tham số null
  factory WeatherSyncSettings.defaults() {
    return const WeatherSyncSettings(
      cityKey: 'hcm',
      intervalMinutes: 15,
      wifiOnly: false,
      chargingOnly: false,
      batteryNotLow: true,
      alertEnabled: true,
      thresholdC: 34,
      workerEnabled: false,
    );
  }

  WeatherCity get city =>
      WeatherCity.byKey(cityKey);


  WeatherSyncSettings copyWith({
    String? cityKey,
    int? intervalMinutes,
    bool? wifiOnly,
    bool? chargingOnly,
    bool? batteryNotLow,
    bool? alertEnabled,
    double? thresholdC,
    bool? workerEnabled,
  }) {
    return WeatherSyncSettings(
      cityKey: cityKey ?? this.cityKey,
      intervalMinutes:
          intervalMinutes ?? this.intervalMinutes,
      wifiOnly: wifiOnly ?? this.wifiOnly,
      chargingOnly:
          chargingOnly ?? this.chargingOnly,
      batteryNotLow:
          batteryNotLow ?? this.batteryNotLow,
      alertEnabled:
          alertEnabled ?? this.alertEnabled,
      thresholdC:
          thresholdC ?? this.thresholdC,
      workerEnabled:
          workerEnabled ?? this.workerEnabled,
    );
  }
}