import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../data/datasources/task17_remote_data_source.dart';
import '../../domain/models/task17_models.dart';


class Task17SocialController extends ChangeNotifier {
  Task17SocialController({
    Task17RemoteDataSource? remote, }) : _remote= remote ?? Task17RemoteDataSource();

  final Task17RemoteDataSource _remote;

  Task17Profile? profile;
  List<Task17Post> posts=[];

  bool profileLoading=false;
  bool postsLoading=false;

  String? profileError;
  String? postsError;

  int apiUserId=1;

  // lấy id tài khoản demo sang user id của api mẫu
  int _apiId(User user) {
    final total=user.uid.codeUnits.fold<int>( 0, (sum,value)=>sum+value, );

    return (total%10)+1;
  }

  // tải hsơ và ds bài viết cho trang t.khoản
  Future<void> loadAll( User user, ) async {
    apiUserId=_apiId(user);

    await Future.wait([
      loadProfile(user), loadPosts(user), ]);
  }

  // tải lại ttin hồ sơ để hthị trạng thái mới nhất
  Future<void> loadProfile( User user, ) async {
    apiUserId=_apiId(user);

    profileLoading=true;
    profileError=null;
    notifyListeners();

    try {
      profile=await _remote.getProfile( apiUserId, );
    } catch(e) {
      profileError=e.toString() .replaceFirst( 'Exception: ', '', );
    } finally {
      profileLoading=false;
      notifyListeners();
    }
  }

  // lấy danh sách bài viết và cập nhật bộ lọc đang sử dụng.
  Future<void> loadPosts( User user, ) async {
    apiUserId=_apiId(user);

    postsLoading=true;
    postsError=null;
    notifyListeners();

    try {
      posts=await _remote.getPosts( apiUserId, );
    } catch(e) {
      postsError=e.toString() .replaceFirst( 'Exception: ', '', );
    } finally {
      postsLoading=false;
      notifyListeners();
    }
  }

  List<Task17Post> searchPosts( String query, ) {
    final text=query.trim().toLowerCase();

    if(text.isEmpty) {
      return posts;
    }

    return posts.where((post) {
      return post.title .toLowerCase() .contains(text) || post.body .toLowerCase() .contains(text);
    }).toList();
  }
}
