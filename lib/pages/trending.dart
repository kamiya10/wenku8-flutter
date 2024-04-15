import 'package:flutter/material.dart';
import 'package:wenku/widgets/page/stateful_page.dart';

class TrendingPage extends StatefulPage {
  const TrendingPage({super.key});

  @override
  String get pageTitle => "排行榜";

  @override
  State<TrendingPage> createState() => _TrendingPageState();
}

class _TrendingPageState extends State<TrendingPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return const Placeholder();
  }
}
