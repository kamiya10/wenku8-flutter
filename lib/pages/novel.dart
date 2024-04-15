import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:wenku/api/wenku8.dart';
import 'package:wenku/models/novel.dart';
import 'package:wenku/utils/extensions/build_context.dart';

class NovelPage extends StatelessWidget {
  final Novel novel;

  const NovelPage({super.key, required this.novel});

  @override
  Widget build(BuildContext context) {
    final titleTextStyle = TextStyle(
      color: context.colors.primary,
      fontSize: 16,
    );

    final detailTextStyle = TextStyle(
      color: context.colors.onSurfaceVariant,
      fontSize: 14,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(novel.title!),
      ),
      body: ListView(
        children: [
          Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Hero(
                    tag: "novel_thumbnail_${novel.id}",
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        width: 66.66666667,
                        height: 100,
                        imageUrl: Wenku8Api.getCoverURL(novel.id),
                        progressIndicatorBuilder: (context, url, downloadProgress) {
                          return Center(child: CircularProgressIndicator(value: downloadProgress.progress));
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
                          tag: "novel_title_${novel.id}",
                          child: Material(
                            color: Colors.transparent,
                            child: Text(
                              novel.title!,
                              overflow: TextOverflow.ellipsis,
                              style: titleTextStyle,
                            ),
                          ),
                        ),
                        const Divider(
                          height: 6,
                        ),
                        Text(
                          "總點擊數：${novel.totalHitsCount!}",
                          style: detailTextStyle,
                        ),
                        Text(
                          "總推薦數：${novel.pushCount!}",
                          style: detailTextStyle,
                        ),
                        Text(
                          "總收藏數：${novel.favCount!}",
                          style: detailTextStyle,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: FutureBuilder(
              future: Wenku8Api.getNovelFullIntro(novel.id),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(snapshot.data);
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          FutureBuilder(
            future: Wenku8Api.getNovelVolumes(novel.id),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<Widget> v = [];

                for (var volume in snapshot.data!) {
                  v.add(
                    Card(
                      elevation: 4,
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        child: Text(volume.name),
                      ),
                    ),
                  );
                }
                return Column(
                  children: v,
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ],
      ),
    );
  }
}
