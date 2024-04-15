import 'dart:collection';
import 'dart:convert';

import 'package:wenku/api/light_network.dart';
import 'package:wenku/models/chapter.dart';
import 'package:wenku/models/novel.dart';
import 'package:wenku/models/volume.dart';
import 'package:xml/xml.dart';

enum NovelSortBy {
  // sort arguments:
  // allvisit 总排行榜; allvote 总推荐榜; monthvisit 月排行榜; monthvote 月推荐榜;
  // weekvisit 周排行榜; weekvote 周推荐榜; dayvisit 日排行榜; dayvote 日推荐榜;
  // postdate 最新入库; lastupdate 最近更新; goodnum 总收藏榜; size 字数排行;
  // fullflag 完结列表
  allVisit,
  allVote,
  monthVisit,
  monthVote,
  weekVisit,
  weekVote,
  dayVisit,
  dayVote,
  postDate,
  lastUpdate,
  goodNum,
  size,
  fullFlag
}

extension NovelSortByExtension on NovelSortBy {
  String get value => name.toLowerCase();
}

class Wenku8Api {
  static const String baseUrl = "http://app.wenku8.com/android.php";
  static const String relayUrl = "https://wenku8-relay.mewx.org/";

  // This part are the old API writing ways.
  // It's not efficient enough, and maybe bug-hidden.
  static Map<String, String> getEncryptedMap(String str) {
    print("getEncryptedMap -> $str");

    Map<String, String> params = HashMap();
    params["appver"] = "1.18.0"; // DateTime.now().millisecondsSinceEpoch
    params["request"] = base64Encode(utf8.encode(str));
    params["timetoken"] = "${DateTime.now().millisecondsSinceEpoch}";
    return params;
  }

  static String getCoverURL(int id) {
    return "http://img.wenku8.com/image/${(id / 1000).floor()}/$id/${id}s.jpg";
  }

  static Future getNovelList(NovelSortBy sortBy, int page) {
    // here get a specific list of novels, sorted by NOVELSORTBY
    // ---------------------------------------------------------
    // <?xml version="1.0" encoding="utf-8"?>
    // <result>
    // <page num='166'/>
    // <item aid='1143'/>
    // <item aid='1034'/>
    // <item aid='1213'/>
    // <item aid='1'/>
    // <item aid='1011'/>
    // <item aid='1192'/>
    // <item aid='433'/>
    // <item aid='47'/>
    // <item aid='7'/>
    // <item aid='374'/>
    // </result>

    return LightNetwork.lightHttpPostConnection(
      relayUrl,
      getEncryptedMap("action=articlelist&sort=${sortBy.value}&page=$page"),
    );
  }

  static Future<List<Novel>> getNovelListWithInfo(NovelSortBy sortBy, int page) async {
    // get novel list with info digest
    // -------------------------------
    // <?xml version="1.0" encoding="utf-8"?>
    // <result>
    // <page num='166'/>
    //
    // <item aid='1034'>
    // <data name='Title'><![CDATA[恶魔高校DxD(High School DxD)]]></data>
    // <data name='TotalHitsCount' value='2316361'/>
    // <data name='PushCount' value='153422'/>
    // <data name='FavCount' value='14416'/>
    // <data name='Author' value='xxx'/>
    // <data name='BookStatus' value='xxx'/>
    // <data name='LastUpdate' value='xxx'/>
    // <data name='IntroPreview' value='xxx'/>
    // </item>
    // ...... ......
    // </result>

    final data = await LightNetwork.lightHttpPostConnection(
      relayUrl,
      getEncryptedMap("action=novellist&sort=${sortBy.value}&page=$page&t=1"),
    );

    final doc = XmlDocument.parse(data);
    List<Novel> novels = [];

    for (var p0 in doc.childElements) {
      for (var p1 in p0.childElements) {
        if (p1.name.toString() == "item") {
          novels.add(Novel.fromXml(p1));
        }
      }
    }

    return novels;
  }

  static Future getNovelFullIntro(int id) async {
    // get full XML intro of a novel, here is an example:
    // --------------------------------------------------
    // 　　在劍與魔法作為一股強大力量的世界裡，克雷歐過著只有繪畫是唯一生存意義的孤獨生活。
    // 　　不過生於名門的他，為了取得繼承人資格必須踏上試煉之旅。
    // 　　踏入禁忌森林的他，遇見一名半人半植物的魔物。
    // 　　輕易被抓的克雷歐設法勾起少女的興趣得到幫助，卻又被她當成寵物一般囚禁起來。
    // 　　兩人從此展開不可思議的同居時光，這樣的生活令他感到很安心。
    // 　　但平靜的日子沒有持續太久……
    // 　　描繪人與魔物的戀情，溫暖人心的奇幻故事。
    String data = await LightNetwork.lightHttpPostConnection(
      relayUrl,
      getEncryptedMap("action=book&do=intro&aid=$id&t=1"),
    );
    return data;
  }

  static Future getNovelFullMeta(int id) {
    // get full XML metadata of a novel, here is an example:
    // -----------------------------------------------------
    // <?xml version="1.0" encoding="utf-8"?>
    // <metadata>
    // <data name="Title"
    // aid="1306"><![CDATA[向森之魔物献上花束(向森林的魔兽少女献花)]]></data>
    // <data name="Author" value="小木君人"/>
    // <data name="DayHitsCount" value="26"/>
    // <data name="TotalHitsCount" value="43984"/>
    // <data name="PushCount" value="1735"/>
    // <data name="FavCount" value="848"/>
    // <data name="PressId" value="小学馆" sid="10"/>
    // <data name="BookStatus" value="已完成"/>
    // <data name="BookLength" value="105985"/>
    // <data name="LastUpdate" value="2012-11-02"/>
    // <data name="LatestSection" cid="41897"><![CDATA[第一卷 插图]]></data>
    // </metadata>
    return LightNetwork.lightHttpPostConnection(
      relayUrl,
      getEncryptedMap("action=book&do=meta&aid=$id&t=1"),
    );
  }

  static Future<List<Volume>> getNovelVolumes(int id) async {
    // get full XML index of a novel, here is an example:
    // --------------------------------------------------
    // <?xml version="1.0" encoding="utf-8"?>
    // <package>
    // <volume vid="41748"><![CDATA[第一卷 告白于苍刻之夜]]>
    // <chapter cid="41749"><![CDATA[序章]]></chapter>
    // <chapter cid="41750"><![CDATA[第一章「去对我的『楯』说吧——」]]></chapter>
    // <chapter cid="41751"><![CDATA[第二章「我真的对你非常感兴趣」]]></chapter>
    // <chapter cid="41752"><![CDATA[第三章「揍我吧！」]]></chapter>
    // <chapter cid="41753"><![CDATA[第四章「下次，再来喝苹果茶」]]></chapter>
    // <chapter cid="41754"><![CDATA[第五章「这是约定」]]></chapter>
    // <chapter cid="41755"><![CDATA[第六章「你的背后——由我来守护！」]]></chapter>
    // <chapter cid="41756"><![CDATA[第七章「茱莉——爱交给你！」]]></chapter>
    // <chapter cid="41757"><![CDATA[尾声]]></chapter>
    // <chapter cid="41758"><![CDATA[后记]]></chapter>
    // <chapter cid="41759"><![CDATA[插图]]></chapter>
    // </volume>
    // <volume vid="45090"><![CDATA[第二卷 谎言、真相与赤红]]>
    // <chapter cid="45091"><![CDATA[序章]]></chapter>
    // <chapter cid="45092"><![CDATA[第一章「莉莉丝·布里斯托」]]></chapter>
    // <chapter cid="45093"><![CDATA[第二章「借你的话来说就是……」]]></chapter>
    // <chapter cid="45094"><![CDATA[第三章「这真是个好提议」]]></chapter>
    // <chapter cid="45095"><![CDATA[第四章「如守护骑士一般」]]></chapter>
    // <chapter cid="45096"><![CDATA[第五章「『咬龙战』，开始！」]]></chapter>
    // <chapter cid="45097"><![CDATA[第六章「超越人类的存在」]]></chapter>
    // <chapter cid="45098"><![CDATA[第七章「『灵魂』」]]></chapter>
    // <chapter cid="45099"><![CDATA[尾声]]></chapter>
    // <chapter cid="45100"><![CDATA[后记]]></chapter>
    // <chapter cid="45105"><![CDATA[插图]]></chapter>
    // </volume>
    // ...... ......
    // </package>
    String data = await LightNetwork.lightHttpPostConnection(
      relayUrl,
      getEncryptedMap("action=book&do=list&aid=$id&t=1"),
    );

    final doc = XmlDocument.parse(data);
    List<Volume> volumes = [];

    for (var p0 in doc.childElements) {
      for (var p1 in p0.childElements) {
        if (p1.name.toString() == "volume") {
          volumes.add(Volume.fromXml(p1));
        }
      }
    }

    return volumes;
  }

  static Future getNovelContent(int id, int cid) {
    // get full content of an article of a novel,
    // the images should be processed then, here is an example:
    // --------------------------------------------------------
    // 第一卷 告白于苍刻之夜 插图
    // ...... ......
    // <!--image-->http://pic.wenku8.cn/pictures/1/1305/41759/50471.jpg<!--image-->
    // <!--image-->http://pic.wenku8.cn/pictures/1/1305/41759/50472.jpg<!--image-->
    // <!--image-->http://pic.wenku8.cn/pictures/1/1305/41759/50473.jpg<!--image-->
    // ...... ......
    return LightNetwork.lightHttpPostConnection(
      relayUrl,
      getEncryptedMap("action=book&do=text&aid=$id&cid=$cid&t=1"),
    );
  }
}
