

class PostDeepLinkParser {
  const PostDeepLinkParser._();

  static int? parse(String raw) {
    final value = raw.trim();

    if (value.isEmpty) {
      return null;
    }


    final uri = Uri.tryParse(value);   // Uri.tryParse tránh exception if chuỗi dán vào k phải uri h.lệ

    if (uri == null) {
      return null;
    }

    return parseUri(uri);
  }

  static int? parseUri(Uri uri) {
    if (uri.scheme.toLowerCase() != 'myapp') {
      return null;
    }

    // xử lý host post
    if (uri.host.toLowerCase() != 'post') {
      return null;
    }

    if (uri.pathSegments.length != 1) {
      return null;
    }

    //chặn id <= 0 trước khi sang api

    final id = int.tryParse(uri.pathSegments.first);

    if (id == null || id <= 0) {
      return null;
    }

    return id;
  }

  static String buildPostLink(int id) {
    return 'myapp://post/$id';
  }
}