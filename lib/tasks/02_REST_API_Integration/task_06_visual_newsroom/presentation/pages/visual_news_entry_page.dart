import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../data/datasources/news_local_data_source.dart';
import '../../data/datasources/news_remote_data_source.dart';
import '../../data/datasources/unsplash_remote_data_source.dart';

import '../../data/repositories/visual_news_repository.dart';
import 'visual_news_page.dart';


class VisualNewsEntryPage extends StatefulWidget {
  const VisualNewsEntryPage({super.key});

  @override
  State<VisualNewsEntryPage> createState() => _VisualNewsEntryPageState();
}

class _VisualNewsEntryPageState extends State<VisualNewsEntryPage> {
  late final VisualNewsRepository repository;

  @override

  void initState() {
    super.initState();
    final dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10)));
    repository = VisualNewsRepository(
      newsRemote: NewsRemoteDataSource(dio: dio),
      unsplashRemote: UnsplashRemoteDataSource(dio: dio),
      local: NewsLocalDataSource(),
    );
  }

  @override

  Widget build(BuildContext context) => VisualNewsPage(repository: repository);
}
