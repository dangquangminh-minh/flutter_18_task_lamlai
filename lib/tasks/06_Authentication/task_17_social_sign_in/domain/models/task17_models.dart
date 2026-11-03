// model lưu hồ sơ và bài viết phục vụ giao diện lịch sử.
class Task17Profile {
  const Task17Profile({
    required this.id, required this.name, required this.username, required this.email,
    required this.phone, required this.website, required this.street, required this.suite,
    required this.city, required this.zipcode, required this.lat, required this.lng,
    required this.companyName, required this.companyCatchPhrase, });

  final int id;
  final String name;
  final String username;
  final String email;
  final String phone;
  final String website;
  final String street;
  final String suite;
  final String city;

  final String zipcode;
  
  final String lat;
  final String lng;
  final String companyName;
  final String companyCatchPhrase;

  factory Task17Profile.fromJson( Map<String,dynamic> json, ) {
    final address=Map<String,dynamic>.from( json['address'] as Map? ?? {}, );

    final geo=Map<String,dynamic>.from( address['geo'] as Map? ?? {}, );

    final company=Map<String,dynamic>.from( json['company'] as Map? ?? {}, );

    return Task17Profile( id:(json['id'] as num?)?.toInt() ?? 0, name:json['name']?.toString() ?? '',
      username:json['username']?.toString() ?? '', email:json['email']?.toString() ?? '',
      phone:json['phone']?.toString() ?? '', website:json['website']?.toString() ?? '',
      street:address['street']?.toString() ?? '', suite:address['suite']?.toString() ?? '',
      city:address['city']?.toString() ?? '', zipcode:address['zipcode']?.toString() ?? '',
      lat:geo['lat']?.toString() ?? '', lng:geo['lng']?.toString() ?? '',
      companyName:company['name']?.toString() ?? '', companyCatchPhrase:
          company['catchPhrase']?.toString() ?? '', );
  }
}

class Task17Post {
  const Task17Post({
    required this.userId, required this.id, required this.title, required this.body, });

  final int userId;
  final int id;
  final String title;
  final String body;

  factory Task17Post.fromJson( Map<String,dynamic> json, ) {
    return Task17Post( userId:(json['userId'] as num?)?.toInt() ?? 0,
      id:(json['id'] as num?)?.toInt() ?? 0, title:json['title']?.toString() ?? '',
      body:json['body']?.toString() ?? '', );
  }
}
