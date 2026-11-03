import 'package:flutter/material.dart';

const task18Primary=Color(0xFF9E2A45);
const task18PrimaryContainer=Color(0xFFC23E56);
const task18Background=Color(0xFFFBF6F5);
const task18Text=Color(0xFF191C1D);
const task18SecondaryText=Color(0xFF5B646B);
const task18Soft=Color(0xFFF1F2F3);


class Task18SurfaceCard extends StatelessWidget {
  const Task18SurfaceCard({
    super.key, required this.child, this.padding=const EdgeInsets.all(18), });
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context)=>Container( padding:padding, decoration:BoxDecoration(
      color:Colors.white, borderRadius:BorderRadius.circular(22),
      border:Border.all(color:const Color(0xFFECEEEF)), boxShadow:const [
        BoxShadow(color:Color(0x0E000000),blurRadius:22,offset:Offset(0,8)), ], ),
    child:child, );
}

class Task18StatusChip extends StatelessWidget {
  const Task18StatusChip({
    super.key, required this.icon, required this.label, this.active=false, });
  final IconData icon;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context)=>Container(
    padding:const EdgeInsets.symmetric(horizontal:10,vertical:6), decoration:BoxDecoration(
      color:active ? const Color(0xFFFFE6EB) : const Color(0xFFEDEFF1),
      borderRadius:BorderRadius.circular(30), ),
    child:Row( mainAxisSize:MainAxisSize.min, children:[
        Icon(icon,size:14,color:active ? task18Primary : task18SecondaryText), const SizedBox(width:5),
        Flexible( child:Text( label, overflow:TextOverflow.ellipsis, style:TextStyle( fontSize:10,
              fontWeight:FontWeight.w700, color:active ? task18Primary : task18SecondaryText, ), ), ), ],
    ), );
}

class Task18StateCard extends StatelessWidget {
  const Task18StateCard({
    super.key, required this.icon, required this.title, required this.message, this.onRetry, });
  final IconData icon;
  final String title;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context)=>Task18SurfaceCard( child:Column( children:[
        Container( width:58,height:58, decoration:const BoxDecoration(
            color:Color(0xFFFFE8E5),shape:BoxShape.circle, ),
          child:Icon(icon,color:task18Primary,size:28), ),
        const SizedBox(height:14), Text( title, textAlign:TextAlign.center, style:const TextStyle(
            color:task18Text,fontSize:17,fontWeight:FontWeight.w800, ), ),
        const SizedBox(height:7), Text( message, textAlign:TextAlign.center, style:const TextStyle(
            color:task18SecondaryText,fontSize:12,height:1.5, ), ),
        if(onRetry!=null) ...[
          const SizedBox(height:16), FilledButton.icon( onPressed:onRetry,
            style:FilledButton.styleFrom(backgroundColor:task18Primary),
            icon:const Icon(Icons.refresh_rounded), label:const Text('Thử lại'), ), ], ], ), );
}

String task18FormatPopulation(int value) {
  if(value>=1000000000) return '${(value/1000000000).toStringAsFixed(1)}B';
  if(value>=1000000) return '${(value/1000000).toStringAsFixed(1)}M';
  if(value>=1000) return '${(value/1000).toStringAsFixed(1)}K';
  return '$value';
}
