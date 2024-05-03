import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:wenku8/api/wenku8.dart';
import 'package:wenku8/models/chapter.dart';
import 'package:wenku8/models/novel.dart';
import 'package:wenku8/pages/image_viewer.dart';
import 'package:wenku8/pages/reader.dart';
import 'package:wenku8/utils/extensions/build_context.dart';

class NovelPage extends StatelessWidget {
  final Novel novel;
  final String titleHeroTag;
  final String thumbnailHeroTag;

  const NovelPage({super.key, required this.novel, required this.titleHeroTag, required this.thumbnailHeroTag});

  @override
  Widget build(BuildContext context) {
    final titleTextStyle = context.theme.textTheme.titleMedium!.copyWith(color: context.colors.primary);
    final detailTextStyle = context.theme.textTheme.bodyMedium!.copyWith(color: context.colors.onSurfaceVariant);

    return Scaffold(
      appBar: AppBar(
        title: Text(novel.title!),
      ),
      body: ListView(
        children: [
          Card(
            elevation: 4,
            shadowColor: Colors.transparent,
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(children: [
                      Hero(
                        tag: thumbnailHeroTag,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            width: 66.66666667,
                            height: 100,
                            imageUrl: Wenku8Api.getCoverURL(novel.id),
                            progressIndicatorBuilder: (context, url, downloadProgress) {
                              return Center(
                                child: CircularProgressIndicator(value: downloadProgress.progress),
                              );
                            },
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return ImageViewer(
                                      child: Hero(
                                        tag: thumbnailHeroTag,
                                        child: CachedNetworkImage(
                                          imageUrl: Wenku8Api.getCoverURL(novel.id),
                                          progressIndicatorBuilder: (context, url, downloadProgress) {
                                            return Center(
                                                child: CircularProgressIndicator(value: downloadProgress.progress));
                                          },
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Hero(
                          tag: titleHeroTag,
                          child: Material(
                            color: Colors.transparent,
                            child: Text(
                              novel.title!,
                              style: titleTextStyle,
                            ),
                          ),
                        ),
                        const Divider(height: 6),
                        Text(
                          "作者：${novel.author!}",
                          style: detailTextStyle,
                        ),
                        Text(
                          "連載狀態：${novel.status!}",
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
            shadowColor: Colors.transparent,
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "小說簡介",
                    style: context.theme.textTheme.titleMedium!.copyWith(
                      color: context.colors.secondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  FutureBuilder(
                    future: Wenku8Api.getNovelFullIntro(novel.id),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: snapshot.data!.map((p) {
                            return Text(p, style: detailTextStyle);
                          }).toList(),
                        );
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          FutureBuilder(
            future: Wenku8Api.getNovelVolumes(novel.id),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<Widget> v = [];

                for (var volume in snapshot.data!) {
                  List<Widget> c = [];

                  for (Chapter chapter in volume.chapters) {
                    c.add(
                      Card(
                        elevation: 4,
                        clipBehavior: Clip.antiAlias,
                        shadowColor: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) {
                                return Reader(
                                  id: novel.id,
                                  cid: chapter.id,
                                  title: chapter.name,
                                );
                              },
                            ));
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(chapter.name),
                          ),
                        ),
                      ),
                    );
                  }

                  v.add(
                    Card(
                      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      shadowColor: Colors.transparent,
                      clipBehavior: Clip.antiAlias,
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          dividerColor: Colors.transparent, // if you want to remove the border
                        ),
                        child: ExpansionTile(
                          dense: true,
                          visualDensity: VisualDensity.comfortable,
                          title: Text(
                            volume.name,
                          ),
                          textColor: context.colors.primary,
                          expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
                          childrenPadding: const EdgeInsets.all(4),
                          children: c,
                        ),
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
