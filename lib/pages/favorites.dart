import 'package:flutter/material.dart';
import 'package:wenku/widgets/page/stateful_page.dart';

class FavoritesPage extends StatefulPage {
  const FavoritesPage({super.key});

  @override
  String get pageTitle => "我的收藏";

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return const Placeholder();
  }
}
