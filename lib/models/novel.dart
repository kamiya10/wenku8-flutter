import 'package:wenku8/api/wenku8.dart';
import 'package:xml/xml.dart';

class Novel {
  final int id;
  String? title;
  String? author;
  String? status;
  int? totalHitsCount;
  int? pushCount;
  int? favCount;
  DateTime? lastUpdate;
  List<String>? tags;

  Novel({
    required this.id,
    this.title,
    this.author,
    this.status,
    this.totalHitsCount,
    this.pushCount,
    this.favCount,
    this.lastUpdate,
    this.tags,
  });

  static Novel fromXml(XmlElement xml) {
    int id = int.parse(xml.attributes[0].value);
    Novel n = Novel(id: id);

    for (var data in xml.childElements) {
      switch (data.attributes[0].value) {
        case "Title":
          n.title = data.innerText;
          break;
        case "TotalHitsCount":
          n.totalHitsCount = int.parse(data.attributes[1].value);
          break;
        case "PushCount":
          n.pushCount = int.parse(data.attributes[1].value);
          break;
        case "FavCount":
          n.favCount = int.parse(data.attributes[1].value);
          break;
        case "Author":
          n.author = data.attributes[1].value;
          break;
        case "BookStatus":
          n.status = data.attributes[1].value;
          break;
        case "LastUpdate":
          n.lastUpdate = DateTime.parse(data.attributes[1].value);
          break;
        case "Tags":
          n.tags = data.attributes[1].value.split(" ");
          break;
      }
    }
    return n;
  }

  String get thumbnailUrl => Wenku8Api.getCoverURL(id);
}
