import 'package:url_launcher/url_launcher.dart';

Future<bool> openTrailerUri(Uri uri) {
  return launchUrl(
    uri,
    mode: LaunchMode.platformDefault,
    webOnlyWindowName: '_blank',
  );
}
