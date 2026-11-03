
class CampusProfile {
  const CampusProfile({
    required this.id, required this.name, required this.username, required this.email,
    required this.phone, required this.website, required this.city, required this.company, });

  final int id;
  final String name;
  final String username;
  final String email;
  final String phone;
  final String website;

  final String city;
  final String company;


  factory CampusProfile.fromJson( Map<String, dynamic> json, ) {
    final address = json['address'] is Map
            ? Map<String, dynamic>.from( json['address'], )
            : <String, dynamic>{};

    final company = json['company'] is Map
            ? Map<String, dynamic>.from( json['company'], )
            : <String, dynamic>{};

    return CampusProfile( id: (json['id'] as num?) ?.toInt() ?? 0, name: json['name']?.toString() ??
              'Không có tên',
      username: json['username'] ?.toString() ?? '', email: json['email']?.toString() ?? '', phone:
          json['phone']?.toString() ?? '',
      website: json['website'] ?.toString() ?? '', city: address['city'] ?.toString() ?? '', company:
          company['name'] ?.toString() ?? '', );
  }
}
