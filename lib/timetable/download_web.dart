import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html';

download(String name, List<int> data) {
  final _base64 = base64Encode(data);
  final anchor = AnchorElement(
    href: 'data:application/octet-stream;base64,$_base64',
  )..target = 'blank';
  anchor.download = name;
  anchor.click();
}
