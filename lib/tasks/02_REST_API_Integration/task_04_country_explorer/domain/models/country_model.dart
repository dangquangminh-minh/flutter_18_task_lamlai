// Model gọn cho danh sách và trang chi tiết ở Bài 4.
// countries.dev dùng name/flags/alpha2Code, khác REST Countries v5 của Bài 3.
// Mỗi đối tượng tương ứng một quốc gia, chỉ giữ các trường giao diện thật sự cần.
class CountryModel {
  const CountryModel({
    required this.commonName,
    required this.flagUrl,
    required this.capitalName,
    required this.region,
    required this.population,
    required this.code,
    required this.subregion,
    required this.flagEmoji,
  });

  // Tách tên, cờ, thủ đô, khu vực và dân số thành thuộc tính để Widget dùng thống nhất.
  final String commonName;
  final String flagUrl;
  final String capitalName;
  final String region;
  final int population;
  final String code;
  final String subregion;
  final String flagEmoji;

  // Chuẩn hóa JSON bên ngoài tại một nơi; giao diện không trực tiếp truy cập key từ API.
  factory CountryModel.fromJson(Map<String, dynamic> json) {
    final name = json['name'];
    // API có thể trả thủ đô dạng chuỗi hoặc mảng, nên xử lý cả hai dạng.
    final capitals = json['capital'];
    final flags = json['flags'];
    final flag = json['flag'];

    String capital = 'Chưa rõ thủ đô';
    if (capitals is String && capitals.trim().isNotEmpty) {
      capital = capitals;
    } else if (capitals is List && capitals.isNotEmpty) {
      capital = capitals.first.toString();
    }


    String image = '';

    if (flags is Map) {

      image = flags['png']?.toString() ?? flags['svg']?.toString() ?? '';
    }
    if (image.isEmpty && flag is String && flag.startsWith('http')) {

          image = flag;
    }

    // các giá trị mặc định giúp app không vỡ giao diện khi api thiếu dl
    return CountryModel(
      commonName: name is String && name.isNotEmpty ? name : 'Không rõ',
      flagUrl: image,
      capitalName: capital,
      region: json['region']?.toString() ?? 'Khác',
      population: (json['population'] as num?)?.toInt() ?? 0,
      code: json['alpha2Code']?.toString() ?? '',
      subregion: json['subregion']?.toString() ?? 'Chưa rõ',

      flagEmoji: flag is String && !flag.startsWith('http') ? flag : '🌍',
    );
  }
}
