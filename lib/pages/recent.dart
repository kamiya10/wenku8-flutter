import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:wenku8/api/wenku8.dart';
import 'package:wenku8/models/novel.dart';
import 'package:wenku8/pages/novel.dart';
import 'package:wenku8/utils/extensions/build_context.dart';
import 'package:wenku8/widgets/page/stateful_page.dart';

class RecentPage extends StatefulPage {
  const RecentPage({super.key});

  @override
  String get pageTitle => "最近更新";

  @override
  State<RecentPage> createState() => _RecentPageState();
}

class _RecentPageState extends State<RecentPage> with AutomaticKeepAliveClientMixin {
  final _scrollController = ScrollController();
  final initLoadData = Completer();
  List<Novel> novels = [];
  bool isLoading = false;
  int _currentPage = 1;
  int _loadedPage = 0;

  void _loadMore() {
    if (isLoading) return;
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      setState(() {
        _currentPage++;
        _fetchNextPage();
      });
    }
  }

  Future<void> _fetchNextPage() async {
    if (isLoading) return;
    if (_currentPage <= _loadedPage) {
      setState(() {
        _currentPage = _loadedPage;
      });
      return;
    }

    isLoading = true;
    final n = await Wenku8Api.getNovelListWithInfo(NovelSortBy.lastUpdate, _currentPage);

    setState(() {
      novels.addAll(n);
      _loadedPage = _currentPage;
      isLoading = false;
    });

    if (!initLoadData.isCompleted) initLoadData.complete();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_loadMore);
    _fetchNextPage();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final titleTextStyle = context.theme.textTheme.titleMedium!.copyWith(color: context.colors.primary);
    final detailTextStyle = context.theme.textTheme.bodyMedium!.copyWith(color: context.colors.onSurfaceVariant);

    return initLoadData.isCompleted
        ? ListView.builder(
            shrinkWrap: true,
            controller: _scrollController,
            itemCount: novels.length,
            itemBuilder: (context, index) {
              return Card(
                elevation: 4,
                shadowColor: Colors.transparent,
                clipBehavior: Clip.antiAlias,
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimatio) {
                          return NovelPage(
                              titleHeroTag: "novel_thumbnail_${novels[index].id}_$index",
                              thumbnailHeroTag: "novel_title_${novels[index].id}_$index",
                              novel: novels[index]);
                        },
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          const begin = 0.0;
                          const end = 1.0;
                          const curve = Curves.ease;

                          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                          return FadeTransition(
                            opacity: animation.drive(tween),
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        Hero(
                          tag: "novel_thumbnail_${novels[index].id}_$index",
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              width: 66.66666667,
                              height: 100,
                              imageUrl: Wenku8Api.getCoverURL(novels[index].id),
                              progressIndicatorBuilder: (context, url, downloadProgress) {
                                return Center(
                                  child: CircularProgressIndicator(value: downloadProgress.progress),
                                );
                              },
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Hero(
                                tag: "novel_title_${novels[index].id}_$index",
                                child: Material(
                                  color: Colors.transparent,
                                  child: Text(
                                    novels[index].title!,
                                    overflow: TextOverflow.ellipsis,
                                    style: titleTextStyle,
                                  ),
                                ),
                              ),
                              const Divider(
                                height: 6,
                              ),
                              Text(
                                "總點擊數：${novels[index].totalHitsCount!}",
                                style: detailTextStyle,
                              ),
                              Text(
                                "總推薦數：${novels[index].pushCount!}",
                                style: detailTextStyle,
                              ),
                              Text(
                                "總收藏數：${novels[index].favCount!}",
                                style: detailTextStyle,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          )
        : const Center(child: CircularProgressIndicator());
  }
}
