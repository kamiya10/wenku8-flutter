import 'package:flutter/material.dart';
import 'package:wenku8/api/wenku8.dart';
import 'package:wenku8/utils/extensions/build_context.dart';

class Reader extends StatefulWidget {
  final int id;
  final int cid;
  final String title;

  const Reader({super.key, required this.id, required this.cid, required this.title});

  @override
  State<Reader> createState() => _ReaderState();
}

class _ReaderState extends State<Reader> {
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
                itemCount: data.length,
                itemBuilder: (context, index) {
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
