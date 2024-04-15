import 'dart:convert'; // for encoding data
import 'dart:io'; // for HttpClient

class LightNetwork {
  static Future<String> lightHttpPostConnection(String url, Map<String, String> values) async {
    final httpClient = HttpClient();
    httpClient.autoUncompress = false;
    try {
      final uri = Uri.parse(url);
      final request = await httpClient.postUrl(uri);
      request.headers.set(HttpHeaders.acceptEncodingHeader, 'gzip');
      /*
        if (withSession and LightUserSession.session.isNotEmpty) {
          request.headers.set(HttpHeaders.cookieHeader, 'PHPSESSID=${LightUserSession.session}');
        }
      */
      request.followRedirects = true;

      // prepare request body
      final params = values.entries.map((entry) => '${entry.key}=${entry.value}').join('&');

      print("params -> $params");
      final encodedParams = utf8.encode(params);
      request.add(encodedParams);

      final response = await request.close();
      if (response.statusCode != HttpStatus.ok) {
        throw Exception('HTTP error ${response.statusCode}');
      }

      final responseStream = response;

      var stream = await responseStream.expand((e) => e).toList();

      return utf8.decode(GZipCodec().decode(stream));
    } catch (e) {
      print(e);
      return "";
    } finally {
      httpClient.close();
    }
  }
}
