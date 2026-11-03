import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/datasources/profile_remote_data_source.dart';
import '../../data/repositories/auth_repository.dart';
import '../../domain/models/campus_profile.dart';
import '../widgets/campus_auth_widgets.dart';


class CampusProfilePage extends StatefulWidget {
  const CampusProfilePage({
    super.key, required this.repository, });

  final AuthRepository repository;

  @override
  State<CampusProfilePage> createState() => _CampusProfilePageState();
}

class _CampusProfilePageState extends State<CampusProfilePage> {
  late final ProfileRemoteDataSource source;

  late Future<CampusProfile> profileFuture;

  @override
  void initState() {
    super.initState();

    source = ProfileRemoteDataSource( dio: Dio(), );

    profileFuture = source.fetchProfile();
  }

  // tải lại dữ liệu khi api thất bại or ng.dùng muốn làm mới
  void _retry() {
    setState(() {
      profileFuture = source.fetchProfile();
    });
  }



  // đưa ra xác nhận rồi kết thúc phiên đăng nhập hiện tại
  Future<void> _logout() async {
    final confirm = await showDialog<bool>( context: context, builder: (context) {
        return AlertDialog( title: const Text( 'Đăng xuất?', ), content: const Text(
            'Phiên Firebase Authentication '
            'trên thiết bị này sẽ kết thúc.', ),
          actions: [
            TextButton( onPressed: () {
                Navigator.pop( context, false, );
              }, child: const Text( 'Hủy', ), ),
            FilledButton( onPressed: () {
                Navigator.pop( context, true, );
              }, child: const Text( 'Đăng xuất', ), ), ], );
      }, );

    if (confirm == true) {
      await widget.repository .logout();
    }
  }



  @override
  Widget build( BuildContext context, ) {
    final User? user = widget.repository.currentUser;

    return Scaffold( backgroundColor: campusBackground, appBar: AppBar( backgroundColor: campusGreen,
        foregroundColor: Colors.white, leading: IconButton(tooltip: 'Về trang chủ',
          onPressed: () => context.go('/'), icon: const Icon(Icons.home_rounded)),
        title: const Text('Student Profile'), actions: [
          IconButton( onPressed: _logout, icon: const Icon( Icons.logout, ), ), ], ),
      body: RefreshIndicator( color: campusGreen, onRefresh: () async {
          _retry();
          await profileFuture;
        }, child: ListView( padding: const EdgeInsets.all( 16, ), children: [
            CampusCard( child: Column( children: [
                  Container( width: 90, height: 90, decoration: const BoxDecoration( color: campusMint,
                      shape: BoxShape.circle, ),
                    child: const Icon( Icons .person_outline, size: 45, color: campusGreen, ), ),

                  const SizedBox( height: 12, ),

                  Text( user?.email ?? 'Firebase User', textAlign: TextAlign.center, style:
                        const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 19, ), ),

                  const SizedBox( height: 6, ),

                  Container( padding: const EdgeInsets .symmetric( horizontal: 10, vertical: 5, ),
                    decoration: BoxDecoration( color: campusMint, borderRadius: BorderRadius.circular(
                        20, ), ),
                    child: const Row( mainAxisSize: MainAxisSize.min, children: [
                        Icon( Icons .verified, color: campusGreen, size: 16, ), SizedBox( width: 4, ),
                        Text( 'Firebase Verified', style: TextStyle( color: campusGreen, fontWeight:
                                FontWeight.w600,
                            fontSize: 11, ), ), ], ), ), ], ), ),

            const SizedBox( height: 14, ),

            CampusCard( child: Column( crossAxisAlignment: CrossAxisAlignment .start, children: [
                  const Text( 'Bảo mật & phiên xác thực', style: TextStyle( fontWeight: FontWeight.bold,
                      fontSize: 16, ), ),

                  const SizedBox( height: 10, ),

                  _info( 'UID', user?.uid ?? '-', ),

                  _info( 'Email', user?.email ?? '-', ),

                  _info( 'Email verified', user?.emailVerified == true
                        ? 'Có'
                        : 'Chưa', ),

                  _info( 'Provider', user ?.providerData .map( (e) => e.providerId, ) .join( ', ', ) ??
                        '-', ), ], ), ),

            const SizedBox( height: 14, ),

            const Text( 'Hồ sơ mẫu từ JSONPlaceholder', style: TextStyle( fontWeight: FontWeight.bold,
                fontSize: 16, ), ),

            const SizedBox( height: 8, ),

            FutureBuilder< CampusProfile>( future: profileFuture, builder: (context, snapshot) {
                if (snapshot .connectionState == ConnectionState .waiting) {
                  return const CampusCard( child: Padding( padding: EdgeInsets.all( 24, ), child: Center(
                        child: CircularProgressIndicator( color: campusGreen, ), ), ), );
                }

                if (snapshot.hasError) {
                  return CampusCard( child: Column( children: [
                        const Icon( Icons .cloud_off_outlined, color: Colors.redAccent, size: 38, ),
                        const SizedBox( height: 8, ), Text( '${snapshot.error}', textAlign:
                              TextAlign.center, ),
                        const SizedBox( height: 8, ), OutlinedButton.icon( onPressed: _retry, icon:
                              const Icon(
                            Icons.refresh, ),
                          label: const Text( 'Thử lại', ), ), ], ), );
                }

                final profile = snapshot.data!;

                return CampusCard( child: Column( crossAxisAlignment: CrossAxisAlignment .start,
                    children: [
                      Text( profile.name, style: const TextStyle( fontWeight: FontWeight.bold, fontSize:
                              20, ), ),
                      Text( '@${profile.username}', style: const TextStyle( color: Colors.black45, ), ),
                      const Divider( height: 26, ), _info( 'Email mẫu', profile.email, ), _info(
                        'Điện thoại', profile.phone, ),
                      _info( 'Website', profile.website, ), _info( 'Thành phố', profile.city, ), _info(
                        'Công ty', profile.company, ), ], ), );
              }, ),

            const SizedBox( height: 14, ),

            SizedBox( height: 50, child: OutlinedButton.icon( style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red, ),
                onPressed: _logout, icon: const Icon( Icons.logout, ), label: const Text(
                  'Đăng xuất tài khoản', ), ), ), ], ), ), );
  }

  Widget _info( String title, String value, ) {
    return Container( margin: const EdgeInsets.only( bottom: 7, ), padding: const EdgeInsets.all( 10, ),
      decoration: BoxDecoration( color: const Color( 0xFFF1F4FB, ), borderRadius: BorderRadius.circular(
          10, ), ),
      child: Row( crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox( width: 105, child: Text( title, style: const TextStyle( color: Colors.black54,
                fontSize: 11, ), ), ),
          Expanded( child: Text( value, textAlign: TextAlign.right, style: const TextStyle( fontWeight:
                    FontWeight.w600,
                fontSize: 11, ), ), ), ], ), );
  }
}
