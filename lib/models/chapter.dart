import 'package:xml/xml.dart';

class Chapter {
  final int id;
  final String name;

  const Chapter({required this.id, required this.name});

  static Chapter fromXml(XmlElement xml) {
    int id = int.parse(xml.attributes[0].value);

    return Chapter(id: id, name: xml.innerText);
  }
}
