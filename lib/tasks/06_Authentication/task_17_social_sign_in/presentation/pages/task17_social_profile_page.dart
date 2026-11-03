import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/repositories/task17_auth_repository.dart';
import '../controllers/task17_social_controller.dart';
import '../widgets/task17_widgets.dart';
import 'task17_post_history_page.dart';


class Task17SocialProfilePage extends StatefulWidget {
  const Task17SocialProfilePage({
    super.key, required this.repository, required this.user, });

  final Task17AuthRepository repository;
  final User user;

  @override
  State<Task17SocialProfilePage> createState() => _Task17SocialProfilePageState();
}

class _Task17SocialProfilePageState extends State<Task17SocialProfilePage> {
  late final Task17SocialController controller;

  bool providerBusy = false;

  @override
  void initState() {
    super.initState();

    controller = Task17SocialController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadAll( FirebaseAuth.instance.currentUser ?? widget.user, );
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> linkGoogle() async {
    setState(() {
      providerBusy = true;
    });

    try {
      await widget.repository.linkGoogleToCurrentUser();

      await FirebaseAuth.instance.currentUser?.reload();

      if (!mounted) return;

      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar( const SnackBar( content: Text(
            'Đã liên kết tài khoản Google.', ), ), );
    } on Task17AuthException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar( SnackBar( content: Text(e.message), ), );
    } finally {
      if (mounted) {
        setState(() {
          providerBusy = false;
        });
      }
    }
  }

  // hủy lk  gg khi tài khoản còn phương thức xác thực khác
  Future<void> unlinkGoogle() async {
    final confirm = await showDialog<bool>( context: context, builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(22), ), title: const Text(
          'Hủy liên kết Google?', style: TextStyle( fontWeight: FontWeight.w800, ), ),
        content: const Text( 'Bạn vẫn có thể đăng nhập bằng email và mật khẩu.', ), actions: [
          TextButton( onPressed: () => Navigator.pop(context, false), child: const Text('Hủy'), ),
          FilledButton( onPressed: () => Navigator.pop(context, true), style: FilledButton.styleFrom(
              backgroundColor: task17Orange, ),
            child: const Text('Xác nhận'), ), ], ), );

    if (confirm != true) return;

    setState(() {
      providerBusy = true;
    });

    try {
      await widget.repository.unlinkGoogle();

      await FirebaseAuth.instance.currentUser?.reload();

      if (!mounted) return;

      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar( const SnackBar( content: Text(
            'Đã hủy liên kết tài khoản Google.', ), ), );
    } on Task17AuthException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar( SnackBar( content: Text(e.message), ), );
    } finally {
      if (mounted) {
        setState(() {
          providerBusy = false;
        });
      }
    }
  }

  // k.thúc phiên firebase
  Future<void> logout() async {
    final ok = await showDialog<bool>( context: context, builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(22), ), title: const Text(
          'Đăng xuất?', style: TextStyle( fontWeight: FontWeight.w800, ), ),
        content: const Text( 'Bạn có chắc muốn đăng xuất khỏi tài khoản này?', ), actions: [
          TextButton( onPressed: () => Navigator.pop(context, false), child: const Text('Ở lại'), ),
          FilledButton( onPressed: () => Navigator.pop(context, true), style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFC62828), ),
            child: const Text('Đăng xuất'), ), ], ), );

    if (ok == true) {
      await widget.repository.logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser ?? widget.user;

    final providers = user.providerData .map((e) => e.providerId) .toSet();

    final googleLinked = providers.contains('google.com');

    final passwordLinked = providers.contains('password');

    return Scaffold( backgroundColor: const Color(0xFFF8F6F4), body: AnimatedBuilder(
        animation: controller, builder: (context, _) {
          return RefreshIndicator( color: task17Orange, onRefresh: () => controller.loadAll(user),
            child: CustomScrollView( physics: const AlwaysScrollableScrollPhysics(), slivers: [
                SliverAppBar(pinned: true, elevation: 0,
                  leading: IconButton(tooltip: 'Về trang chủ',
                    onPressed: () => context.go('/'), icon: const Icon(Icons.home_rounded)),
                  backgroundColor: const Color(0xFFF8F6F4),
                  surfaceTintColor: Colors.transparent, title: const Text( 'Tài khoản', style: TextStyle(
                      color: task17Text, fontWeight: FontWeight.w800, ), ),
                  actions: [
                    IconButton( tooltip: 'Làm mới', onPressed: () => controller.loadAll(user),
                      icon: const Icon( Icons.refresh_rounded, color: task17Text, ), ),
                    const SizedBox(width: 6), ], ),

                SliverPadding( padding: const EdgeInsets.fromLTRB( 18, 8, 18, 40, ), sliver: SliverList(
                    delegate: SliverChildListDelegate( [
                        _profileHero( user, googleLinked, ),

                        const SizedBox(height: 18),

                        _sectionTitle( 'Phương thức đăng nhập', 'Quản lý các tài khoản được liên kết', ),

                        const SizedBox(height: 10),

                        _accountCard( googleLinked: googleLinked, passwordLinked: passwordLinked, ),

                        const SizedBox(height: 22),

                        _sectionTitle( 'Thông tin cá nhân', 'Thông tin hồ sơ của bạn', ),

                        const SizedBox(height: 10),

                        if (controller .profileLoading && controller.profile == null)
                          _loadingCard()
                        else if (controller .profileError != null && controller.profile == null)
                          Task17StatePanel( icon: Icons .cloud_off_rounded, title:
                                'Không tải được thông tin',
                            message: controller .profileError!, onRetry: () => controller .loadProfile(
                              user, ), )
                        else if (controller .profile != null)
                          _profileInformation(),

                        const SizedBox(height: 22),

                        _sectionTitle( 'Hoạt động', 'Nội dung gần đây của tài khoản', ),

                        const SizedBox(height: 10),

                        _activityCard( context, user, ),

                        const SizedBox(height: 18),

                        _logoutButton(), ], ), ), ), ], ), );
        }, ), );
  }

  Widget _profileHero( User user, bool googleLinked, ) {
    return Container( padding: const EdgeInsets.fromLTRB( 22, 28, 22, 24, ), decoration: BoxDecoration(
        gradient: const LinearGradient( begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [
            Color(0xFFC63D00), Color(0xFFE65F1C), ], ),
        borderRadius: BorderRadius.circular(30), boxShadow: const [
          BoxShadow( color: Color(0x30A43700), blurRadius: 28, offset: Offset(0, 12), ), ], ),
      child: Column( children: [
          Stack( clipBehavior: Clip.none, children: [
              _avatar(user), Positioned( right: -2, bottom: 1, child: Container( width: 28, height: 28,
                  decoration: BoxDecoration( color: Colors.white, shape: BoxShape.circle,
                    border: Border.all( color: const Color(0xFFE65F1C), width: 2, ), ),
                  child: const Icon( Icons.verified_rounded, size: 18, color: task17Orange, ), ), ), ],
          ),

          const SizedBox(height: 16),

          Text( user.displayName?.trim().isNotEmpty == true
                ? user.displayName!
                : 'Tài khoản sinh viên',
            textAlign: TextAlign.center, style: const TextStyle( color: Colors.white, fontSize: 23,
              fontWeight: FontWeight.w800, letterSpacing: -0.4, ), ),

          const SizedBox(height: 5),

          Text( user.email ?? '', textAlign: TextAlign.center, style: const TextStyle(
              color: Color(0xFFEFEFEF), fontSize: 13, ), ),

          const SizedBox(height: 16),

          Container( padding: const EdgeInsets.symmetric( horizontal: 13, vertical: 7, ),
            decoration: BoxDecoration( color: Colors.white.withValues(alpha: .16), borderRadius:
                  BorderRadius.circular(30),
              border: Border.all( color: Colors.white.withValues(alpha: .18), ), ),
            child: Row( mainAxisSize: MainAxisSize.min, children: [
                Icon( googleLinked
                      ? Icons .check_circle_rounded
                      : Icons .account_circle_outlined,
                  color: Colors.white, size: 17, ),
                const SizedBox(width: 6), Text( googleLinked
                      ? 'Google đã liên kết'
                      : 'Tài khoản đang hoạt động',
                  style: const TextStyle( color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600,
                  ), ), ], ), ), ], ), );
  }

  Widget _accountCard({
    required bool googleLinked, required bool passwordLinked, }) {
    return _surfaceCard( child: Column( children: [
          _accountRow( icon: Icons.mail_outline_rounded, iconBackground: const Color(0xFFFFEEE7),
            title: 'Email & mật khẩu', subtitle: passwordLinked
                ? 'Có thể dùng để đăng nhập'
                : 'Chưa được thiết lập',
            linked: passwordLinked, ),

          const Padding( padding: EdgeInsets.symmetric(vertical: 6), child: Divider( height: 1,
              color: Color(0xFFF0E9E5), ), ),

          _googleAccountRow( googleLinked: googleLinked, passwordLinked: passwordLinked, ), ], ), );
  }

  Widget _googleAccountRow({
    required bool googleLinked, required bool passwordLinked, }) {
    return Padding( padding: const EdgeInsets.symmetric(vertical: 7), child: Row( children: [
          Container( width: 46, height: 46, decoration: BoxDecoration( color: const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(15), ),
            alignment: Alignment.center, child: const Task17GoogleMark(), ),

          const SizedBox(width: 12),

          Expanded( child: Column( crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text( 'Google', style: TextStyle( color: task17Text, fontSize: 14,
                    fontWeight: FontWeight.w700, ), ),
                const SizedBox(height: 3), Text( googleLinked
                      ? 'Đã liên kết với tài khoản'
                      : 'Đăng nhập nhanh bằng Google',
                  style: const TextStyle( color: Colors.black45, fontSize: 11, ), ), ], ), ),

          if (providerBusy)
            const SizedBox( width: 22, height: 22, child: CircularProgressIndicator( strokeWidth: 2,
                color: task17Orange, ), )
          else if (!googleLinked)
            TextButton( onPressed: linkGoogle, child: const Text( 'Liên kết', style: TextStyle(
                  color: task17Orange, fontWeight: FontWeight.w700, ), ), )
          else if (passwordLinked)
            TextButton( onPressed: unlinkGoogle, child: const Text( 'Hủy liên kết', style: TextStyle(
                  color: Color(0xFFB42318), fontSize: 12, ), ), )
          else
            _linkedBadge(), ], ), );
  }

  Widget _accountRow({
    required IconData icon, required Color iconBackground, required String title,
    required String subtitle, required bool linked, }) {
    return Padding( padding: const EdgeInsets.symmetric(vertical: 7), child: Row( children: [
          Container( width: 46, height: 46, decoration: BoxDecoration( color: iconBackground,
              borderRadius: BorderRadius.circular(15), ),
            child: Icon( icon, color: task17Orange, size: 22, ), ),

          const SizedBox(width: 12),

          Expanded( child: Column( crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text( title, style: const TextStyle( color: task17Text, fontWeight: FontWeight.w700,
                    fontSize: 14, ), ),
                const SizedBox(height: 3), Text( subtitle, style: const TextStyle( color: Colors.black45,
                    fontSize: 11, ), ), ], ), ),

          linked
              ? _linkedBadge()
              : const Text( 'Chưa có', style: TextStyle( color: Colors.black38, fontSize: 11, ), ), ], ),
    );
  }

  Widget _linkedBadge() {
    return Container( padding: const EdgeInsets.symmetric( horizontal: 9, vertical: 5, ),
      decoration: BoxDecoration( color: const Color(0xFFE8F6EC), borderRadius: BorderRadius.circular(20),
      ), child: const Row( mainAxisSize: MainAxisSize.min, children: [
          Icon( Icons.check_rounded, size: 13, color: Color(0xFF2D7D46), ), SizedBox(width: 3), Text(
            'Đã liên kết', style: TextStyle( color: Color(0xFF2D7D46), fontSize: 10,
              fontWeight: FontWeight.w700, ), ), ], ), );
  }

  Widget _profileInformation() {
    final p = controller.profile!;

    return _surfaceCard( child: Column( children: [
          _infoRow( icon: Icons.person_outline_rounded, title: 'Họ và tên', value: p.name, ), _divider(),
          _infoRow( icon: Icons .alternate_email_rounded, title: 'Tên người dùng',
            value: '@${p.username}', ),
          _divider(), _infoRow( icon: Icons.email_outlined, title: 'Email', value: p.email, ),
          _divider(), _infoRow( icon: Icons.phone_outlined, title: 'Điện thoại', value: p.phone, ),
          _divider(), _infoRow( icon: Icons.location_on_outlined, title: 'Địa chỉ', value:
                '${p.street}, ${p.suite}, ${p.city}', ),
          _divider(), _infoRow( icon: Icons .business_outlined, title: 'Công ty', value: p.companyName,
          ), _divider(), _infoRow( icon: Icons.language_rounded, title: 'Website', value: p.website, ),
        ], ), );
  }

  Widget _activityCard( BuildContext context, User user, ) {
    return _surfaceCard( padding: EdgeInsets.zero, child: InkWell( borderRadius:
            BorderRadius.circular(24),
        onTap: () {
          Navigator.push( context, MaterialPageRoute( builder: (_) => Task17PostHistoryPage(
                controller: controller, user: user, ), ), );
        }, child: Padding( padding: const EdgeInsets.all(18), child: Row( children: [
              Container( width: 52, height: 52, decoration: BoxDecoration( color:
                      const Color(0xFFFFEEE7),
                  borderRadius: BorderRadius.circular(17), ),
                child: const Icon( Icons.article_outlined, color: task17Orange, size: 25, ), ),

              const SizedBox(width: 14),

              Expanded( child: Column( crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text( 'Lịch sử bài viết', style: TextStyle( color: task17Text, fontSize: 15,
                        fontWeight: FontWeight.w700, ), ),
                    const SizedBox(height: 4), Text( controller.postsLoading
                          ? 'Đang cập nhật...'
                          : '${controller.posts.length} bài viết',
                      style: const TextStyle( color: Colors.black45, fontSize: 11, ), ), ], ), ),

              const Icon( Icons .arrow_forward_ios_rounded, color: Colors.black26, size: 17, ), ], ), ),
      ), );
  }

  Widget _logoutButton() {
    return SizedBox( height: 54, child: OutlinedButton.icon( onPressed: logout,
        style: OutlinedButton.styleFrom( foregroundColor: const Color(0xFFB42318), backgroundColor:
              const Color(0xFFFFF6F5),
          side: const BorderSide( color: Color(0xFFF4C7C2), ), shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18), ), ),
        icon: const Icon( Icons.logout_rounded, size: 20, ), label: const Text( 'Đăng xuất',
          style: TextStyle( fontWeight: FontWeight.w700, ), ), ), );
  }

  Widget _surfaceCard({
    required Widget child, EdgeInsetsGeometry padding = const EdgeInsets.all(17), }) {
    return Container( padding: padding, decoration: BoxDecoration( color: Colors.white, borderRadius:
            BorderRadius.circular(24),
        border: Border.all( color: const Color(0xFFF0E9E5), ), boxShadow: const [
          BoxShadow( color: Color(0x0D000000), blurRadius: 20, offset: Offset(0, 7), ), ], ),
      child: child, );
  }

  Widget _sectionTitle( String title, String subtitle, ) {
    return Column( crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text( title, style: const TextStyle( color: task17Text, fontSize: 17,
            fontWeight: FontWeight.w800, ), ),
        const SizedBox(height: 3), Text( subtitle, style: const TextStyle( color: Colors.black38,
            fontSize: 11, ), ), ], );
  }

  Widget _infoRow({
    required IconData icon, required String title, required String value, }) {
    return Padding( padding: const EdgeInsets.symmetric( vertical: 11, ), child: Row( crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container( width: 36, height: 36, decoration: BoxDecoration( color: const Color(0xFFFFF1EA),
              borderRadius: BorderRadius.circular(11), ),
            child: Icon( icon, size: 18, color: task17Orange, ), ),

          const SizedBox(width: 11),

          Expanded( child: Column( crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text( title, style: const TextStyle( color: Colors.black45, fontSize: 10, ), ),
                const SizedBox(height: 3), Text( value, style: const TextStyle( color: task17Text,
                    fontWeight: FontWeight.w600, fontSize: 12, height: 1.35, ), ), ], ), ), ], ), );
  }

  Widget _divider() {
    return const Divider( height: 1, color: Color(0xFFF0E9E5), );
  }

  Widget _loadingCard() {
    return _surfaceCard( child: const Padding( padding: EdgeInsets.symmetric(vertical: 24),
        child: Center( child: Column( children: [
              CircularProgressIndicator( color: task17Orange, strokeWidth: 2.5, ), SizedBox(height: 12),
              Text( 'Đang tải thông tin...', style: TextStyle( color: Colors.black45, fontSize: 12, ), ),
            ], ), ), ), );
  }

  Widget _avatar(User user) {
    final photo = user.photoURL;

    return Container( width: 94, height: 94, decoration: BoxDecoration( shape: BoxShape.circle,
        color: Colors.white, border: Border.all( color: Colors.white, width: 4, ), boxShadow: const [
          BoxShadow( color: Color(0x30000000), blurRadius: 16, offset: Offset(0, 6), ), ], ),
      clipBehavior: Clip.antiAlias, child: photo == null
          ? const Icon( Icons.person_rounded, size: 48, color: task17Orange, )
          : Image.network( photo, fit: BoxFit.cover, errorBuilder: (_, _, _) => const Icon(
                Icons.person_rounded, size: 48, color: task17Orange, ), ), );
  }
}
