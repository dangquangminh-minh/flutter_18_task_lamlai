import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/country/country_bloc.dart';
import '../bloc/country/country_event.dart';
import '../bloc/favorite/favorite_cubit.dart';
import '../travel_theme.dart';
import 'country_search_page.dart';
import 'offline_saved_page.dart';

class TravelMainPage extends StatefulWidget {
  const TravelMainPage({super.key});

  @override
  State<TravelMainPage> createState()=>_TravelMainPageState();
}

class _TravelMainPageState extends State<TravelMainPage> {
  int currentIndex=0;

  @override
  void initState() {
    super.initState();
    // tải ds qg và đọc ds yêu thích từ hive
    context.read<CountryBloc>().add(const CountryStarted());
    context.read<FavoriteCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:travelBackground,
      appBar:AppBar(
        backgroundColor:travelBackground,
        surfaceTintColor:Colors.transparent,
        elevation:0,
        titleSpacing:18,
        title:Row(
          children:[
            Container(
              width:40,
              height:40,
              decoration:BoxDecoration(
                gradient:const LinearGradient(
                  colors:[travelPrimaryContainer,travelPrimary],
                ),
                borderRadius:BorderRadius.circular(13),
              ),
              child:const Icon(Icons.travel_explore_rounded,color:Colors.white),
            ),
            const SizedBox(width:11),
            Column(
              crossAxisAlignment:CrossAxisAlignment.start,
              children:[
                Text(
                  currentIndex==0 ? 'Khám phá quốc gia' : 'Đã lưu ngoại tuyến',
                  style:const TextStyle(
                    color:travelText,
                    fontSize:18,
                    fontWeight:FontWeight.w900,
                  ),
                ),
                const Text(
                  'Travel Planner Pro',
                  style:TextStyle(color:travelMuted,fontSize:10),
                ),
              ],
            ),
          ],
        ),
      ),
      // giữ nguyên trang thái 2 tab khi chuyên qua lại
      body:IndexedStack(
        index:currentIndex,
        children:const [
          CountrySearchPage(),
          OfflineSavedPage(),
        ],
      ),
      bottomNavigationBar:NavigationBar(
        selectedIndex:currentIndex,
        indicatorColor:const Color(0xFFFFD9DF),
        onDestinationSelected:(index) {
          setState(()=>currentIndex=index);
          if(index==1) context.read<FavoriteCubit>().load();
        },
        destinations:const [
          NavigationDestination(
            icon:Icon(Icons.public_outlined),
            selectedIcon:Icon(Icons.public,color:travelPrimary),
            label:'Khám phá',
          ),
          NavigationDestination(
            icon:Icon(Icons.bookmark_border_rounded),
            selectedIcon:Icon(Icons.bookmark_rounded,color:travelPrimary),
            label:'Đã lưu',
          ),
        ],
      ),
    );
  }
}