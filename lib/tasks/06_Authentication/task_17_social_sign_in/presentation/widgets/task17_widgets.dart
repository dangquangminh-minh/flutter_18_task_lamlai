import 'package:flutter/material.dart';

const task17Orange=Color(0xFFC2491D);
const task17OrangeBright=Color(0xFFE76B32);
const task17OrangeSoft=Color(0xFFFFE7D9);
const task17Background=Color(0xFFFCF7F2);
const task17Surface=Color(0xFFFFF0E6);
const task17Text=Color(0xFF131B2E);


class Task17Card extends StatelessWidget {
  const Task17Card({
    super.key, required this.child, this.padding=const EdgeInsets.all(16), });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container( width:double.infinity, padding:padding, decoration:BoxDecoration(
        color:Colors.white, borderRadius:BorderRadius.circular(20), boxShadow:const [
          BoxShadow( color:Color(0x10000000), blurRadius:18, offset:Offset(0,5), ), ], ),
      child:child, );
  }
}

class Task17GoogleMark extends StatelessWidget {
  const Task17GoogleMark({super.key});

  @override
  Widget build(BuildContext context) {
    return Container( width:34, height:34, decoration:BoxDecoration( color:Colors.white,
        shape:BoxShape.circle, border:Border.all( color:const Color(0xFFE7E7E7), ), ),
      alignment:Alignment.center, child:const Text( 'G', style:TextStyle( color:Color(0xFF4285F4),
          fontWeight:FontWeight.w800, fontSize:20, ), ), );
  }
}

class Task17StatePanel extends StatelessWidget {
  const Task17StatePanel({
    super.key, required this.icon, required this.title, required this.message, this.onRetry, });

  final IconData icon;
  final String title;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Task17Card( child:Column( children:[
          Icon( icon, size:44, color:task17Orange, ), const SizedBox(height:12), Text( title,
            textAlign:TextAlign.center, style:const TextStyle( fontWeight:FontWeight.bold, fontSize:17,
            ), ),
          const SizedBox(height:5), Text( message, textAlign:TextAlign.center, style:const TextStyle(
              color:Colors.black54, ), ),
          if(onRetry!=null) ...[
            const SizedBox(height:14), FilledButton.icon( onPressed:onRetry,
              icon:const Icon(Icons.refresh), label:const Text('Thử lại'), ), ], ], ), );
  }
}
