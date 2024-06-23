import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wenku8/api/wenku8.dart';
import 'package:wenku8/models/novel.dart';
import 'package:wenku8/pages/novel.dart';
import 'package:wenku8/widgets/novel/novel_item.dart';
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

    return initLoadData.isCompleted
        ? ListView.builder(
            shrinkWrap: true,
            controller: _scrollController,
            itemCount: novels.length,
            itemBuilder: (context, index) {
              final novel = novels[index];
              return NovelItem(
                heroTag: "${index}_novel_${novel.id}",
                novel: novel,
                showHitsCount: true,
                showPushCount: true,
                showFavoriteCount: true,
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimatio) {
                        return NovelPage(
                          heroTag: "${index}_novel_${novel.id}",
                          novel: novels[index],
                        );
                      },
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        const begin = 0.0;
                        const end = 1.0;

                        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.ease));

                        return FadeTransition(
                          opacity: animation.drive(tween),
                          child: child,
                        );
                      },
                    ),
                  );
                },
              );
              /*
              return Card(
                elevation: 4,
                shadowColor: Colors.transparent,
                clipBehavior: Clip.antiAlias,
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: InkWell(
                  ,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Hero(
                          tag: "novel_thumbnail_${novels[index].id}_$index",
                          child: CachedNetworkImage(
                            width: (100 / 3) * 2,
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
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
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
              */
            },
          )
        : const Center(child: CircularProgressIndicator());
  }
}
