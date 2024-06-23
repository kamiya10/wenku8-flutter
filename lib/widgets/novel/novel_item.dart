import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:wenku8/models/novel.dart';
import 'package:wenku8/pages/image_viewer.dart';
import 'package:wenku8/utils/extensions/build_context.dart';

class NovelItem extends StatelessWidget {
  final String heroTag;
  final Novel novel;
  final bool showPushCount;
  final bool showFavoriteCount;
  final bool showHitsCount;
  final bool showAuthor;
  final TextOverflow? titleOverflow;
  final void Function()? onTap;

  const NovelItem({
    super.key,
    required this.heroTag,
    required this.novel,
    this.showPushCount = false,
    this.showFavoriteCount = false,
    this.showHitsCount = false,
    this.showAuthor = false,
    this.titleOverflow = TextOverflow.ellipsis,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final novelTitleTextStyle = context.theme.textTheme.titleMedium!.copyWith(color: context.colors.primary);
    final novelDetailTextStyle = context.theme.textTheme.bodyMedium!.copyWith(color: context.colors.onSurface);

    return Card(
      elevation: 4,
      shadowColor: Colors.transparent,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  children: [
                    SizedBox(
                      height: 100,
                      width: (100 / 3) * 2,
                      child: Hero(
                        tag: "${heroTag}_cover",
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: novel.thumbnailUrl,
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
                                  tag: "${heroTag}_cover",
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.zero,
                                    child: CachedNetworkImage(
                                      imageUrl: novel.thumbnailUrl,
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
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Hero(
                      tag: "${heroTag}_title",
                      child: Text(
                        novel.title!,
                        overflow: titleOverflow,
                        style: novelTitleTextStyle,
                      ),
                    ),
                    const Divider(height: 6),
                    if (showAuthor)
                      RichText(
                        text: TextSpan(
                          style: novelDetailTextStyle,
                          children: [
                            const TextSpan(text: "作者："),
                            TextSpan(text: novel.author, style: const TextStyle(decoration: TextDecoration.underline)),
                          ],
                        ),
                      ),
                    if (showHitsCount) Text("總點擊數：${novel.totalHitsCount}", style: novelDetailTextStyle),
                    if (showPushCount) Text("總推薦數：${novel.pushCount}", style: novelDetailTextStyle),
                    if (showFavoriteCount) Text("總收藏數：${novel.favCount}", style: novelDetailTextStyle),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
