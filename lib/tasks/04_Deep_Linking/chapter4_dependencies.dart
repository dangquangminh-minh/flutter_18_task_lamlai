

import 'package:app_links/app_links.dart';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'task_10_post_link_router/data/datasources/post_remote_data_source.dart';
import 'task_10_post_link_router/data/repositories/post_repository.dart';
import 'task_11_country_share_links/data/datasources/country_share_remote_data_source.dart';


import 'task_11_country_share_links/data/repositories/country_share_repository.dart';
import 'task_12_campaign_gateway/services/campaign_coordinator.dart';



class Chapter4Dependencies {
  Chapter4Dependencies._();

  static final Dio dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 12),
      receiveTimeout: const Duration(seconds: 15)));
  static final AppLinks appLinks = AppLinks();
  static final PostRepository posts = PostRepository(remote: PostRemoteDataSource(dio: dio));
  static final CountryShareRepository countries = CountryShareRepository(
    remote: CountryShareRemoteDataSource(dio: dio));
  static bool _ready = false;

  static Future<void> initialize() async {
    if (_ready) return;

    await Hive.initFlutter();
    await CampaignCoordinator.initialize(dio: dio);
    _ready = true;
  }
}
