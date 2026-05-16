import 'package:web/web.dart' as web;

Future<bool> openTrailerUri(Uri uri) async {
  web.window.location.href = uri.toString();
  return true;
}
