import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/task18_constants.dart';
import '../../services/task18_dependencies.dart';
import '../../domain/models/task18_models.dart';
import '../widgets/task18_widgets.dart';


class Task18OfflineProfilePage extends StatefulWidget {
  const Task18OfflineProfilePage({super.key});
  @override
  State<Task18OfflineProfilePage> createState()=>_Task18OfflineProfilePageState();
}

class _Task18OfflineProfilePageState extends State<Task18OfflineProfilePage> {
  Task18TravelSnapshot? snapshot;
  bool loading=true;
  bool unlocked=false;
  bool bioBusy=false;
  bool retryBusy=false;

  String? message;

  @override
  void initState() { super.initState(); _load(); }

  // đọc dữ liệu cache update trạng thái h/thị
  Future<void> _load() async {
    final deps=Task18Dependencies.instance;
    await deps.initialize();
    final cached=await deps.travel.readOffline();
    if(!mounted) return;
    setState((){snapshot=cached;loading=false;});
  }


  Future<void> _unlock() async {
    setState((){bioBusy=true;message=null;});
    final ok=await Task18Dependencies.instance.biometric.authenticate();
    if(!mounted) return;
    setState((){
      bioBusy=false;
      unlocked=ok;
      message=ok
          ? 'Đã mở khóa dữ liệu cá nhân.'
          : 'Không thể xác thực sinh trắc học trên thiết bị này.';
    });
  }

  //  đồng bộ lại dữ liệu khi có internet
  Future<void> _retrySync() async {
    final current=snapshot;
    final user=Task18Dependencies.instance.auth.currentUser;

    if(current==null || user==null) {
      setState(()=>message='Không có phiên đăng nhập để đồng bộ.');
      return;
    }

    setState((){retryBusy=true;message=null;});

    final online=await Task18Dependencies.instance.network.isOnline();
    if(!online) {
      if(!mounted) return;
      setState((){
        retryBusy=false;
        message='Vẫn chưa có kết nối mạng. Vui lòng thử lại sau.';
      });
      return;
    }

    try {
      final fresh=await Task18Dependencies.instance.travel.sync( user:user,
        countryCode:current.country.code, );
      if(!mounted) return;
      setState((){
        snapshot=fresh;
        retryBusy=false;
        message='Đã đồng bộ dữ liệu mới.';
      });
    } catch(e) {
      if(!mounted) return;
      setState((){
        retryBusy=false;
        message=e.toString();
      });
    }
  }

  // yêu cầu xác nhận trước khi xóa cache, đăng xuất
  Future<void> _wipeAndLogout() async {
    final ok=await showDialog<bool>( context:context, builder:(context)=>AlertDialog(
        shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(22)), title:const Text(
          'Xóa dữ liệu ngoại tuyến?', style:TextStyle(fontWeight:FontWeight.w800), ),
        content:const Text( 'Toàn bộ hồ sơ và dữ liệu đã lưu của Bài 18 trên thiết bị sẽ bị xóa.', ),
        actions:[
          TextButton( onPressed:()=>Navigator.pop(context,false), child:const Text('Hủy'), ),
          FilledButton( onPressed:()=>Navigator.pop(context,true),
            style:FilledButton.styleFrom(backgroundColor:Colors.red),
            child:const Text('Xóa & đăng xuất'), ), ], ), );

    if(ok!=true) return;

    final deps=Task18Dependencies.instance;
    await deps.auth.signOut();
    await deps.travel.clearAllCache();

    if(!mounted) return;
    context.go(Task18Constants.loginPath);
  }

  @override
  Widget build(BuildContext context) {
    if(loading) {
      return const Scaffold( backgroundColor:task18Background,
        body:Center(child:CircularProgressIndicator(color:task18Primary)), );
    }

    final data=snapshot;

    return Scaffold( backgroundColor:task18Background, appBar:AppBar( backgroundColor:task18Background,
        surfaceTintColor:Colors.transparent, foregroundColor:task18Text,
        leading: IconButton(tooltip: 'Về trang chủ', onPressed: () => context.go('/'),
          icon: const Icon(Icons.home_rounded)),
        title:const Text(
          'Hồ sơ ngoại tuyến', style:TextStyle(fontWeight:FontWeight.w800), ), ),
      body:data==null
          ? Padding( padding:const EdgeInsets.all(18), child:Task18StateCard(
                icon:Icons.storage_outlined, title:'Chưa có dữ liệu đã lưu',
                message:'Hãy mở Travel Account khi có mạng để tạo bản lưu ngoại tuyến.', onRetry:_load,
              ), )
          : ListView( padding:const EdgeInsets.fromLTRB(18,8,18,36), children:[
                _offlineBanner(), const SizedBox(height:14), _biometricCard(), const SizedBox(height:14),
                _profileCard(data.profile), const SizedBox(height:18), _weatherSection(data),
                if(data.isStale) ...[
                  const SizedBox(height:14), _staleCard(), ],
                if(message!=null) ...[
                  const SizedBox(height:12), _messageCard(message!), ],
                const SizedBox(height:16), SizedBox( height:52, child:FilledButton.icon(
                    onPressed:retryBusy ? null : _retrySync, style:FilledButton.styleFrom(
                      backgroundColor:task18Primary,
                      shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(16)), ),
                    icon:retryBusy
                        ? const SizedBox( width:18,height:18,
                            child:CircularProgressIndicator(strokeWidth:2,color:Colors.white), )
                        : const Icon(Icons.sync_rounded),
                    label:Text( retryBusy ? 'Đang kiểm tra kết nối...' : 'Kết nối lại & đồng bộ', ), ),
                ), const SizedBox(height:10), SizedBox( height:52, child:OutlinedButton.icon(
                    onPressed:_wipeAndLogout, style:OutlinedButton.styleFrom(
                      foregroundColor:Colors.red.shade800, side:BorderSide(color:Colors.red.shade200),
                      shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(16)), ),
                    icon:const Icon(Icons.delete_forever_outlined),
                    label:const Text('Xóa cache & đăng xuất'), ), ), ], ), );
  }

  Widget _offlineBanner()=>Container( padding:const EdgeInsets.all(15), decoration:BoxDecoration(
      color:const Color(0xFF565E74), borderRadius:BorderRadius.circular(20), ),
    child:const Row( crossAxisAlignment:CrossAxisAlignment.start, children:[
        Icon(Icons.wifi_off_rounded,color:Colors.white), SizedBox(width:10), Expanded( child:Column(
            crossAxisAlignment:CrossAxisAlignment.start, children:[
              Text( 'Chế độ ngoại tuyến',
                style:TextStyle(color:Colors.white,fontSize:15,fontWeight:FontWeight.w800), ),
              SizedBox(height:4), Text( 'Đang hiển thị bản dữ liệu gần nhất đã lưu trên thiết bị.',
                style:TextStyle(color:Color(0xFFE1E5EF),fontSize:11,height:1.4), ), ], ), ), ], ), );

  Widget _biometricCard()=>Task18SurfaceCard( child:Column( crossAxisAlignment:CrossAxisAlignment.start,
      children:[
        const Row( children:[
            Icon(Icons.fingerprint_rounded,color:task18Primary,size:28), SizedBox(width:9), Text(
              'Mở khóa dữ liệu cá nhân', style:TextStyle(color:task18Text,fontWeight:FontWeight.w800), ),
          ], ),
        const SizedBox(height:9), const Text(
          'Thông tin nhận dạng được che cho đến khi xác thực sinh trắc học.',
          style:TextStyle(color:task18SecondaryText,fontSize:11,height:1.45), ),
        const SizedBox(height:13), SizedBox( width:double.infinity,height:48, child:FilledButton.icon(
            onPressed:unlocked || bioBusy ? null : _unlock, style:FilledButton.styleFrom(
              backgroundColor:task18Primary,
              shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(14)), ),
            icon:bioBusy
                ? const SizedBox( width:17,height:17,
                    child:CircularProgressIndicator(strokeWidth:2,color:Colors.white), )
                : Icon(unlocked ? Icons.check_circle_rounded : Icons.lock_open_rounded),
            label:Text(unlocked ? 'Đã xác thực' : 'Xác thực bằng sinh trắc học'), ), ), ], ), );

  Widget _profileCard(Task18Profile p)=>Task18SurfaceCard( child:Row( children:[
        Container( width:56,height:56, clipBehavior:Clip.antiAlias, decoration:const BoxDecoration(
            color:Color(0xFFFFE8E5),shape:BoxShape.circle, ),
          child:unlocked && p.photoUrl!=null
              ? Image.network( p.photoUrl!, fit:BoxFit.cover, errorBuilder:(_,_,_)=>const Icon(
                    Icons.person_rounded,color:task18Primary), )
              : const Icon(Icons.person_rounded,color:task18Primary,size:29), ),
        const SizedBox(width:13), Expanded( child:Column( crossAxisAlignment:CrossAxisAlignment.start,
            children:[
              Text( unlocked ? p.name : '••••••••••', style:const TextStyle(
                  color:task18Text,fontSize:16,fontWeight:FontWeight.w800, ), ),
              const SizedBox(height:4), Text( unlocked ? p.email : '••••••@••••.•••',
                style:const TextStyle(color:task18SecondaryText,fontSize:11), ), ], ), ),
        Icon( unlocked ? Icons.verified_user_rounded : Icons.lock_outline_rounded, color:task18Primary,
        ), ], ), );

  Widget _weatherSection(Task18TravelSnapshot d) {
    final c=d.country;
    final w=d.weather;
    return Task18SurfaceCard( child:Column( crossAxisAlignment:CrossAxisAlignment.start, children:[
          const Text( 'Dữ liệu thời tiết đã lưu',
            style:TextStyle(color:task18Text,fontSize:16,fontWeight:FontWeight.w800), ),
          const SizedBox(height:14), Row( children:[
              Container( width:50,height:36, clipBehavior:Clip.antiAlias, decoration:BoxDecoration(
                  color:task18Soft, borderRadius:BorderRadius.circular(8), ),
                child:c.flagUrl.isEmpty
                    ? const Icon(Icons.flag_outlined)
                    : Image.network( c.flagUrl, fit:BoxFit.cover,
                        errorBuilder:(_,_,_)=>const Icon(Icons.flag_outlined), ), ),
              const SizedBox(width:11), Expanded( child:Column(
                  crossAxisAlignment:CrossAxisAlignment.start, children:[
                    Text( '${c.capital}, ${c.name}', style:const TextStyle(
                        color:task18Text,fontWeight:FontWeight.w800, ), ),
                    const SizedBox(height:2), Text( 'Lưu ${_formatTime(d.updatedAt)}',
                      style:const TextStyle(color:task18SecondaryText,fontSize:10), ), ], ), ), ], ),
          const SizedBox(height:14), Container( padding:const EdgeInsets.all(13),
            decoration:BoxDecoration( color:task18Soft, borderRadius:BorderRadius.circular(14), ),
            child:Row( children:[
                Text( '${w.temperatureC.round()}°C', style:const TextStyle(
                    color:task18Text,fontSize:28,fontWeight:FontWeight.w900, ), ),
                const SizedBox(width:10), Expanded( child:Text( w.description,
                    style:const TextStyle(color:task18SecondaryText,fontSize:11), ), ),
                const Task18StatusChip( icon:Icons.offline_pin_rounded,label:'Cache', ), ], ), ), ], ),
    );
  }

  Widget _staleCard()=>Container( padding:const EdgeInsets.all(14), decoration:BoxDecoration(
      color:const Color(0xFFFFE4CC), borderRadius:BorderRadius.circular(18), ),
    child:const Row( crossAxisAlignment:CrossAxisAlignment.start, children:[
        Icon(Icons.history_toggle_off_rounded,color:Color(0xFF8A4300)), SizedBox(width:9), Expanded(
          child:Text( 'Dữ liệu đã quá 24 giờ. Kết nối mạng để cập nhật dự báo mới.',
            style:TextStyle(color:Color(0xFF703A08),fontSize:11,height:1.45), ), ), ], ), );

  Widget _messageCard(String value)=>Container( padding:const EdgeInsets.all(12),
    decoration:BoxDecoration( color:task18Soft, borderRadius:BorderRadius.circular(14), ),
    child:Text(value,style:const TextStyle(color:task18SecondaryText,fontSize:11)), );

  String _formatTime(DateTime value) {
    final d=value.toLocal();
    String two(int n)=>n.toString().padLeft(2,'0');
    return '${two(d.hour)}:${two(d.minute)} ${two(d.day)}/${two(d.month)}/${d.year}';
  }
}
