import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wenku8/api/wenku8.dart';
import 'package:wenku8/global.dart';
import 'package:wenku8/models/chapter.dart';
import 'package:wenku8/models/novel.dart';
import 'package:wenku8/models/volume.dart';
import 'package:wenku8/pages/reader.dart';
import 'package:wenku8/utils/extensions/build_context.dart';
import 'package:wenku8/widgets/novel/novel_item.dart';

class NovelPage extends StatefulWidget {
  final Novel novel;
  final String heroTag;

  const NovelPage({super.key, required this.novel, required this.heroTag});

  @override
  State<NovelPage> createState() => _NovelPageState();
}

class _NovelPageState extends State<NovelPage> {
  Map<int, bool> expandedVolume = {};

  Completer<List<String>> novelFullIntro = Completer();
  Completer<List<Volume>> novelVolumes = Completer();

  Future<List<String>> fetchNovelFullIntro() async {
    final data = await Wenku8Api.getNovelFullIntro(widget.novel.id);
    novelFullIntro.complete(data);
    return data;
  }

  Future<List<Volume>> fetchNovelVolumes() async {
    final data = await Wenku8Api.getNovelVolumes(widget.novel.id);
    novelVolumes.complete(data);
    return data;
  }

  @override
  void initState() {
    super.initState();
    fetchNovelFullIntro();
    fetchNovelVolumes();
  }

  @override
  Widget build(BuildContext context) {
    final detailTextStyle = context.theme.textTheme.bodyMedium!.copyWith(color: context.colors.onSurfaceVariant);
    int? lastReadChapterId = Global.preferences.getInt("last_read:${widget.novel.id}");

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.novel.title!),
      ),
      body: ListView(
        children: [
          NovelItem(
            heroTag: widget.heroTag,
            novel: widget.novel,
            showAuthor: true,
            titleOverflow: TextOverflow.visible,
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
                    future: novelFullIntro.future,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: snapshot.data!.map((p) {
                            return Text(p, style: detailTextStyle);
                          }).toList(),
                        );
                      } else {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          FutureBuilder(
            future: novelVolumes.future,
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
                          onTap: () async {
                            await Navigator.push(context, MaterialPageRoute(
                              builder: (context) {
                                return Reader(
                                  id: widget.novel.id,
                                  cid: chapter.id,
                                  title: chapter.name,
                                );
                              },
                            ));

                            if (chapter.name == "插圖") return;

                            setState(() {
                              lastReadChapterId = chapter.id;
                              Global.preferences.setInt("last_read:${widget.novel.id}", chapter.id);
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (lastReadChapterId == chapter.id)
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 4),
                                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                                    decoration: BoxDecoration(
                                      color: context.colors.secondaryContainer,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      "最後閱讀",
                                      style: TextStyle(
                                        height: 1,
                                        color: context.colors.onSecondaryContainer,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                Text(
                                  chapter.name,
                                  style: lastReadChapterId == chapter.id
                                      ? context.theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold)
                                      : context.theme.textTheme.titleSmall,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );

                    if (lastReadChapterId == chapter.id) {
                      expandedVolume[volume.id] = true;
                    }
                  }

                  v.add(
                    Card(
                      elevation: expandedVolume[volume.id] ?? false ? 16 : 2,
                      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      shadowColor: Colors.transparent,
                      clipBehavior: Clip.antiAlias,
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          dividerColor: Colors.transparent, // if you want to remove the border
                        ),
                        child: ExpansionTile(
                          initiallyExpanded: expandedVolume[volume.id] ?? false,
                          dense: true,
                          visualDensity: VisualDensity.comfortable,
                          title: Text(
                            volume.name,
                          ),
                          textColor: context.colors.primary,
                          expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
                          childrenPadding: const EdgeInsets.all(4),
                          expansionAnimationStyle: AnimationStyle(curve: Easing.standard),
                          children: c,
                          onExpansionChanged: (value) {
                            setState(() {
                              expandedVolume[volume.id] = value;
                            });
                          },
                        ),
                      ),
                    ),
                  );
                }

                return Column(
                  children: v,
                );
              } else {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
