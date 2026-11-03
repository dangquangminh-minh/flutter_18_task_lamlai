import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/task18_constants.dart';
import '../../services/task18_dependencies.dart';
import '../../domain/models/task18_models.dart';
import '../controllers/task18_travel_controller.dart';
import '../widgets/task18_widgets.dart';

class Task18TravelAccountPage extends StatefulWidget {
  const Task18TravelAccountPage({super.key});

  @override
  State<Task18TravelAccountPage> createState()=>_Task18TravelAccountPageState();
}

class _Task18TravelAccountPageState extends State<Task18TravelAccountPage> {
  Task18TravelController? controller;

  User get user=>FirebaseAuth.instance.currentUser!;

  @override
  void initState() {
    super.initState();
    _setup();
  }

  //tải dữ liệu phiên đầu tiên.
  Future<void> _setup() async {
    final deps=Task18Dependencies.instance;
    await deps.initialize();

    final c=Task18TravelController( travel:deps.travel, auth:deps.auth, network:deps.network, );

    if(!mounted) {
      c.dispose();
      return;
    }

    setState(()=>controller=c);
    await c.initialize(user);
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  // đưa ra xác nhận rồi kết thúc phiên đăng nhập htại
  Future<void> _logout() async {
    final ok=await showDialog<bool>( context:context, builder:(context)=>AlertDialog(
        shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(22)),
        title:const Text('Đăng xuất?',style:TextStyle(fontWeight:FontWeight.w800)), content:const Text(
          'Hồ sơ cá nhân lưu cục bộ sẽ được xóa. '
          'Dữ liệu điểm đến công khai vẫn có thể được giữ để xem ngoại tuyến.', ),
        actions:[
          TextButton( onPressed:()=>Navigator.pop(context,false), child:const Text('Hủy'), ),
          FilledButton( onPressed:()=>Navigator.pop(context,true),
            style:FilledButton.styleFrom(backgroundColor:task18Primary), child:const Text('Đăng xuất'),
          ), ], ), );

    if(ok!=true) return;

    await Task18Dependencies.instance.auth.signOut();

    if(!mounted) return;
    context.go(Task18Constants.loginPath);
  }

  // hiển thị ds qg và đồng bộ lại theo lựa chọn
  Future<void> _chooseCountry(Task18TravelController c) async {
    if(!c.online) {
      _toast('Ngoại tuyến: dữ liệu hiện tại chỉ đọc.');
      return;
    }

    const items=<String,String>{
      'VN':'Việt Nam', 'JP':'Nhật Bản', 'FR':'Pháp', 'KR':'Hàn Quốc', 'SG':'Singapore', 'US':'Hoa Kỳ', };

    final code=await showModalBottomSheet<String>( context:context, showDragHandle:true,
      builder:(context)=>SafeArea( child:ListView( shrinkWrap:true, children:[
            const Padding( padding:EdgeInsets.fromLTRB(20,6,20,12), child:Text(
                'Chọn quốc gia yêu thích', style:TextStyle(fontSize:19,fontWeight:FontWeight.w800), ), ),
            ...items.entries.map( (e)=>ListTile( leading:CircleAvatar(
                  backgroundColor:const Color(0xFFFFE8E5), foregroundColor:task18Primary, child:Text(
                    e.key, style:const TextStyle(fontSize:11,fontWeight:FontWeight.w800), ), ),
                title:Text(e.value), trailing:const Icon(Icons.chevron_right_rounded),
                onTap:()=>Navigator.pop(context,e.key), ), ),
            const SizedBox(height:12), ], ), ), );

    if(code!=null) {
      await c.changeFavorite(user,code);
    }
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context) ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content:Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final c=controller;

    if(c==null) {
      return const Scaffold( backgroundColor:task18Background, body:Center(
          child:CircularProgressIndicator(color:task18Primary), ), );
    }

    return Scaffold( backgroundColor:task18Background, appBar:AppBar( backgroundColor:task18Background,
        surfaceTintColor:Colors.transparent, elevation:0, titleSpacing:12,
        leading: IconButton(tooltip: 'Về trang chủ', onPressed: () => context.go('/'),
          icon: const Icon(Icons.home_rounded, color: task18Text)),
        title:const Column(
          crossAxisAlignment:CrossAxisAlignment.start, children:[
            Text( 'Aegis Travel', style:TextStyle(
                color:task18Text,fontSize:18,fontWeight:FontWeight.w900, ), ),
            Text( 'Travel Account', style:TextStyle(color:task18SecondaryText,fontSize:10), ), ], ),
        actions:[
          IconButton( tooltip:'Hồ sơ ngoại tuyến',
            onPressed:()=>context.push(Task18Constants.offlinePath),
            icon:const Icon(Icons.offline_bolt_outlined,color:task18Text), ),
          IconButton( tooltip:'Làm mới', onPressed:c.refreshing ? null : ()=>c.refresh(user),
            icon:c.refreshing
                ? const SizedBox( width:19,height:19,
                    child:CircularProgressIndicator(strokeWidth:2,color:task18Primary), )
                : const Icon(Icons.sync_rounded,color:task18Text), ),
          const SizedBox(width:5), ], ),
      body:AnimatedBuilder( animation:c, builder:(context,_) {
          if(c.state==Task18ViewState.revoked) {
            WidgetsBinding.instance.addPostFrameCallback((_){
              if(mounted) context.go(Task18Constants.loginPath);
            });
          }

          if(c.state==Task18ViewState.loading) {
            return const Center( child:CircularProgressIndicator(color:task18Primary), );
          }

          if(c.state==Task18ViewState.empty) {
            return Padding( padding:const EdgeInsets.all(18), child:Task18StateCard(
                icon:Icons.cloud_off_rounded, title:'Chưa có dữ liệu ngoại tuyến',
                message:c.errorMessage ?? 'Kết nối mạng và đồng bộ ít nhất 1 lần.',
                onRetry:()=>c.refresh(user), ), );
          }

          if(c.state==Task18ViewState.error && c.snapshot==null) {
            return Padding( padding:const EdgeInsets.all(18), child:Task18StateCard(
                icon:Icons.error_outline_rounded, title:'Không tải được dữ liệu',
                message:c.errorMessage ?? 'Đã có lỗi xảy ra.', onRetry:()=>c.refresh(user), ), );
          }

          final s=c.snapshot;
          if(s==null) return const SizedBox.shrink();

          return RefreshIndicator( color:task18Primary, onRefresh:()=>c.refresh(user), child:ListView(
              physics:const AlwaysScrollableScrollPhysics(),
              padding:const EdgeInsets.fromLTRB(18,8,18,36), children:[
                  _profileCard(s,c), const SizedBox(height:20), _sectionTitle( 'Điểm đến yêu thích',
                    c.online ? 'Dữ liệu trực tuyến' : 'Bản lưu ngoại tuyến', ),
                  const SizedBox(height:10), _destinationCard(s,c), const SizedBox(height:20),
                  _sectionTitle( 'Lưu trữ & kết nối', 'Tự động chuyển sang cache khi mất mạng', ),
                  const SizedBox(height:10), _storageCard(s,c), if(c.errorMessage!=null) ...[
                    const SizedBox(height:12), _warningCard(c.errorMessage!), ],
                  const SizedBox(height:18), _actions(), ], ), );
        }, ), );
  }

  Widget _profileCard(Task18TravelSnapshot s,Task18TravelController c) {
    final p=s.profile;

    return Task18SurfaceCard( child:Column( children:[
          Row( children:[
              Container( width:58,height:58, clipBehavior:Clip.antiAlias, decoration:const BoxDecoration(
                  color:Color(0xFFFFE8E5),shape:BoxShape.circle, ),
                child:p.photoUrl==null
                    ? const Icon(Icons.person_rounded,color:task18Primary,size:31)
                    : Image.network( p.photoUrl!, fit:BoxFit.cover, errorBuilder:(_,_,_)=>const Icon(
                          Icons.person_rounded,color:task18Primary,size:31), ), ),
              const SizedBox(width:13), Expanded( child:Column(
                  crossAxisAlignment:CrossAxisAlignment.start, children:[
                    Row( children:[
                        Flexible( child:Text( p.name, overflow:TextOverflow.ellipsis,
                            style:const TextStyle(
                              color:task18Text,fontSize:18,fontWeight:FontWeight.w800, ), ), ),
                        const SizedBox(width:5),
                        const Icon(Icons.verified_rounded,color:task18Primary,size:18), ], ),
                    const SizedBox(height:3), Text( p.email, overflow:TextOverflow.ellipsis,
                      style:const TextStyle(color:task18SecondaryText,fontSize:11), ), ], ), ),
              IconButton( onPressed:c.refreshing ? null : ()=>c.refresh(user),
                icon:const Icon(Icons.sync_rounded), ), ], ),
          const SizedBox(height:16), Container( padding:const EdgeInsets.all(12),
            decoration:BoxDecoration( color:task18Soft, borderRadius:BorderRadius.circular(14), ),
            child:Row( children:[
                const Expanded( child:Task18StatusChip( icon:Icons.verified_user_outlined,
                    label:'Google OAuth', active:true, ), ),
                const SizedBox(width:8), Expanded( child:Task18StatusChip(
                    icon:c.online ? Icons.wifi_rounded : Icons.wifi_off_rounded,
                    label:c.online ? 'Online' : 'Offline', active:c.online, ), ), ], ), ), ], ), );
  }

  Widget _destinationCard(Task18TravelSnapshot s,Task18TravelController c) {
    final country=s.country;
    final weather=s.weather;

    return Task18SurfaceCard( child:Column( children:[
          Row( crossAxisAlignment:CrossAxisAlignment.start, children:[
              Container( width:58,height:42, clipBehavior:Clip.antiAlias, decoration:BoxDecoration(
                  color:task18Soft, borderRadius:BorderRadius.circular(9), ),
                child:country.flagUrl.isEmpty
                    ? const Icon(Icons.flag_outlined)
                    : Image.network( country.flagUrl, fit:BoxFit.cover,
                        errorBuilder:(_,_,_)=>const Icon(Icons.flag_outlined), ), ),
              const SizedBox(width:12), Expanded( child:Column(
                  crossAxisAlignment:CrossAxisAlignment.start, children:[
                    Text( '${country.name} (${country.code})', style:const TextStyle(
                        color:task18Text,fontSize:17,fontWeight:FontWeight.w800, ), ),
                    const SizedBox(height:3), Text( '${country.capital} • ${country.region}',
                      style:const TextStyle(color:task18SecondaryText,fontSize:11), ), ], ), ),
              IconButton( tooltip:'Đổi quốc gia', onPressed:c.online ? ()=>_chooseCountry(c) : null,
                icon:const Icon(Icons.favorite_rounded,color:task18Primary), ), ], ),
          const SizedBox(height:15), Row( children:[
              Expanded(child:_metric('DÂN SỐ',task18FormatPopulation(country.population))),
              Expanded(child:_metric('MÃ VÙNG',country.callingCode.isEmpty ? '—' : country.callingCode)),
              Expanded(child:_metric('MÚI GIỜ',country.timezone.isEmpty ? '—' : country.timezone)), ], ),
          const SizedBox(height:15), Container( padding:const EdgeInsets.all(15),
            decoration:BoxDecoration( color:task18Soft, borderRadius:BorderRadius.circular(16), ),
            child:Row( children:[
                if(weather.iconUrl.isNotEmpty)
                  Image.network( weather.iconUrl, width:54,height:54,
                    errorBuilder:(_,_,_)=>const Icon(Icons.cloud_outlined,size:38), )
                else
                  const Icon(Icons.cloud_outlined,size:38),
                const SizedBox(width:9), Expanded( child:Column(
                    crossAxisAlignment:CrossAxisAlignment.start, children:[
                      Text( '${weather.temperatureC.round()}°C', style:const TextStyle(
                          color:task18Text,fontSize:27,fontWeight:FontWeight.w900, ), ),
                      Text( weather.description,
                        style:const TextStyle(color:task18SecondaryText,fontSize:11), ), ], ), ),
                Column( crossAxisAlignment:CrossAxisAlignment.end, children:[
                    Text( 'Ẩm ${weather.humidity}%',
                      style:const TextStyle(color:task18SecondaryText,fontSize:10), ),
                    const SizedBox(height:5), Text( 'Gió ${weather.windKmh.toStringAsFixed(1)} km/h',
                      style:const TextStyle(color:task18SecondaryText,fontSize:10), ), ], ), ], ), ), ],
      ), );
  }

  Widget _storageCard(Task18TravelSnapshot s,Task18TravelController c)=>Task18SurfaceCard( child:Column(
      crossAxisAlignment:CrossAxisAlignment.start, children:[
        Row( children:[
            const Icon(Icons.storage_rounded,color:task18Primary), const SizedBox(width:9),
            const Expanded( child:Text( 'Bộ nhớ ngoại tuyến',
                style:TextStyle(color:task18Text,fontWeight:FontWeight.w800), ), ),
            const Task18StatusChip( icon:Icons.check_rounded,label:'Đã lưu',active:true, ), ], ),
        const SizedBox(height:9), Text( 'Bản gần nhất: ${_formatTime(s.updatedAt)}',
          style:const TextStyle(color:task18SecondaryText,fontSize:11), ),
        const SizedBox(height:9), Text( c.online
              ? 'Đang kết nối. Có thể đồng bộ và đổi quốc gia yêu thích.'
              : 'Đang ngoại tuyến. Dữ liệu chỉ đọc cho đến khi có mạng.',
          style:const TextStyle(color:task18SecondaryText,fontSize:11,height:1.4), ),
        if(s.isStale) ...[
          const SizedBox(height:12), Container( padding:const EdgeInsets.all(11),
            decoration:BoxDecoration( color:const Color(0xFFFFF0D9),
              borderRadius:BorderRadius.circular(13), ),
            child:const Row( children:[
                Icon(Icons.history_toggle_off_rounded,color:Color(0xFF8A5400),size:18),
                SizedBox(width:8), Expanded( child:Text(
                    'Dữ liệu đã quá 24 giờ. Kết nối mạng để cập nhật.',
                    style:TextStyle(color:Color(0xFF8A5400),fontSize:11), ), ), ], ), ), ], ], ), );

  Widget _actions()=>Column( children:[
      SizedBox( width:double.infinity,height:52, child:OutlinedButton.icon(
          onPressed:()=>context.push(Task18Constants.offlinePath),
          icon:const Icon(Icons.offline_bolt_rounded), label:const Text('Mở hồ sơ ngoại tuyến'),
          style:OutlinedButton.styleFrom( foregroundColor:task18Text,
            shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(16)), ), ), ),
      const SizedBox(height:10), SizedBox( width:double.infinity,height:52, child:FilledButton.icon(
          onPressed:_logout, icon:const Icon(Icons.logout_rounded), label:const Text('Đăng xuất'),
          style:FilledButton.styleFrom( backgroundColor:task18Primary,
            shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(16)), ), ), ), ], );

  Widget _metric(String label,String value)=>Column( children:[
      Text( label, style:const TextStyle(
          color:task18SecondaryText,fontSize:9,fontWeight:FontWeight.w700, ), ),
      const SizedBox(height:5), Text( value, textAlign:TextAlign.center, style:const TextStyle(
          color:task18Text,fontSize:14,fontWeight:FontWeight.w800, ), ), ], );

  Widget _sectionTitle(String title,String subtitle)=>Column(
    crossAxisAlignment:CrossAxisAlignment.start, children:[
      Text( title, style:const TextStyle( color:task18Text,fontSize:17,fontWeight:FontWeight.w900, ), ),
      const SizedBox(height:2), Text( subtitle,
        style:const TextStyle(color:task18SecondaryText,fontSize:10), ), ], );

  Widget _warningCard(String message)=>Container( padding:const EdgeInsets.all(12),
    decoration:BoxDecoration( color:const Color(0xFFFFECE8), borderRadius:BorderRadius.circular(14), ),
    child:Row( children:[
        const Icon(Icons.info_outline_rounded,color:task18Primary,size:19), const SizedBox(width:9),
        Expanded( child:Text( message, style:const TextStyle(color:task18Primary,fontSize:11), ), ), ],
    ), );

  String _formatTime(DateTime value) {
    final d=value.toLocal();
    String two(int n)=>n.toString().padLeft(2,'0');
    return '${two(d.hour)}:${two(d.minute)} ${two(d.day)}/${two(d.month)}/${d.year}';
  }
}
