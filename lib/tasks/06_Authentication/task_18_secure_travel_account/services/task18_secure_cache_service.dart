import 'dart:convert';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'task18_constants.dart';
import '../domain/models/task18_models.dart';


class Task18SecureCacheService {
  Task18SecureCacheService({FlutterSecureStorage? secureStorage})
      : _secureStorage=secureStorage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _secureStorage;
  Box<dynamic>? _box;

  // khởi tạo và đọc cấu hình cần thiết trước khi hiển thị dl
  Future<void> initialize() async {
    if(_box?.isOpen==true) return;
    var encoded=await _secureStorage.read(key:Task18Constants.secureKeyName);
    if(encoded==null) {
      final random=Random.secure();
      final key=List<int>.generate(32,(_)=>random.nextInt(256));
      
      encoded=base64UrlEncode(key);
      await _secureStorage.write(key:Task18Constants.secureKeyName,value:encoded);
    }
    _box=await Hive.openBox<dynamic>( Task18Constants.secureBoxName,
      encryptionCipher:HiveAesCipher(base64Url.decode(encoded)), );
  }

  Box<dynamic> get box {
    final b=_box;
    if(b==null || !b.isOpen) throw StateError('Task18 cache chưa initialize.');
    return b;
  }

  
  Future<void> saveSessionMarker(String uid) async {
    await _secureStorage.write(key:Task18Constants.sessionUidKey,value:uid);  // ghi uid và dấu time của phiên vào secure storage
    await _secureStorage.write( key:Task18Constants.lastAuthAtKey,
      value:DateTime.now().toIso8601String(), );
  }

  Future<void> updateProfile(Task18Profile p)=> box.put(Task18Constants.profileKey,p.toJson());

  // ghi hsơ, qg và weather vào cache hive đã mã hóa
  Future<void> saveSnapshot(Task18TravelSnapshot s) async {
    await box.put(Task18Constants.profileKey,s.profile.toJson());
    await box.put(Task18Constants.countryKey,s.country.toJson());
    await box.put(Task18Constants.weatherKey,s.weather.toJson());
    await box.put(Task18Constants.favoriteCodeKey,s.country.code);
    await box.put(Task18Constants.updatedAtKey,s.updatedAt.toIso8601String());
  }

  String get favoriteCountryCode=>
      box.get(Task18Constants.favoriteCodeKey,defaultValue:'JP')?.toString() ?? 'JP';

  Future<Task18TravelSnapshot?> readSnapshot() async {
    final p=box.get(Task18Constants.profileKey);
    final c=box.get(Task18Constants.countryKey);
    final w=box.get(Task18Constants.weatherKey);
    final t=box.get(Task18Constants.updatedAtKey);
    if(p is! Map || c is! Map || w is! Map || t==null) return null;
    return Task18TravelSnapshot( profile:Task18Profile.fromJson(Map<String,dynamic>.from(p)),
      country:Task18Country.fromCache(Map<String,dynamic>.from(c)),
      weather:Task18Weather.fromCache(Map<String,dynamic>.from(w)),
      updatedAt:DateTime.tryParse(t.toString()) ?? DateTime.fromMillisecondsSinceEpoch(0), );
  }


  Future<bool> hasSnapshot() async=>(await readSnapshot())!=null;


  Future<void> clearSensitive() async {
    await box.delete(Task18Constants.profileKey);
    await _secureStorage.delete(key:Task18Constants.sessionUidKey);
    await _secureStorage.delete(key:Task18Constants.lastAuthAtKey);
  }

  // xóa toàn bộ dl đã cache và dấu phiên 
  Future<void> clearAll() async {
    await box.clear();
    await _secureStorage.delete(key:Task18Constants.sessionUidKey);
    await _secureStorage.delete(key:Task18Constants.lastAuthAtKey);
  }
}
