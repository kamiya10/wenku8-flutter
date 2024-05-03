import 'package:wenku8/models/chapter.dart';
import 'package:xml/xml.dart';

class Volume {
  final int id;
  final String name;
  final List<Chapter> chapters;

  const Volume({required this.id, required this.name, required this.chapters});

  static Volume fromXml(XmlElement xml) {
    int id = int.parse(xml.attributes[0].value);
    List<Chapter> chapters = [];

    for (var p0 in xml.childElements) {
      chapters.add(Chapter.fromXml(p0));
    }

    return Volume(id: id, name: xml.innerText.split("\n").first, chapters: chapters);
  }
}
