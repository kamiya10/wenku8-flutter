import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:wenku8/api/wenku8.dart';
import 'package:wenku8/pages/image_viewer.dart';
import 'package:wenku8/utils/extensions/build_context.dart';

final imageRegex = RegExp(r"(?<=<!--image-->)(\S*?)(?=<!--image-->)");

class Reader extends StatefulWidget {
  final int id;
  final int cid;
  final String title;

  const Reader({super.key, required this.id, required this.cid, required this.title});

  @override
  State<Reader> createState() => _ReaderState();
}

class _ReaderState extends State<Reader> {
  ScrollController contentListViewController = ScrollController();

  Future<List<String>> getContents() async {
    final data = await Wenku8Api.getNovelContent(widget.id, widget.cid);
    return data.split("\n");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              title: Text(widget.title),
              floating: true,
              snap: true,
            )
          ];
        },
        body: FutureBuilder(
          future: getContents(),
          builder: (context, snapshot) {
            final contentTextStyle =
                context.theme.textTheme.bodyLarge!.copyWith(color: context.colors.onSurfaceVariant);

            if (snapshot.hasData) {
              final data = snapshot.data!;

              return ListView.builder(
                controller: contentListViewController,
                itemCount: data.length,
                itemBuilder: (context, index) {
                  if (imageRegex.hasMatch(data[index])) {
                    List<Widget> w = [];

                    for (final Match m in imageRegex.allMatches(data[index])) {
                      String match = m[0]!;
                      String name = match.substring(match.lastIndexOf("/") + 1);

                      w.add(Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Stack(
                            children: [
                              SizedBox(
                                child: Hero(
                                  tag: "illust_${widget.cid}_$name",
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: CachedNetworkImage(
                                      imageUrl: match,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned.fill(
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(
                                      builder: (context) {
                                        return ImageViewer(
                                          child: Hero(
                                            tag: "illust_${widget.cid}_$name",
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.zero,
                                              child: CachedNetworkImage(
                                                imageUrl: match,
                                                progressIndicatorBuilder: (context, url, downloadProgress) {
                                                  return Center(
                                                    child: CircularProgressIndicator(value: downloadProgress.progress),
                                                  );
                                                },
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ));
                                  },
                                ),
                              )
                            ],
                          ),
                        ),
                      ));
                    }
                    return Column(children: w);
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(
                      data[index],
                      style: contentTextStyle,
                    ),
                  );
                },
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}
