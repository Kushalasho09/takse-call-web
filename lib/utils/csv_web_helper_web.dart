import 'dart:convert';
import 'dart:js_interop';
import 'package:web/web.dart' as web;

void pickCsvFileWeb(void Function(String content, String fileName, int fileSize) onFileLoaded) {
  try {
    final uploadInput = web.HTMLInputElement()
      ..type = 'file'
      ..accept = '.csv,text/csv';

    uploadInput.click();

    uploadInput.onChange.listen((event) {
      final files = uploadInput.files;
      if (files == null || files.length == 0) return;

      final file = files.item(0);
      if (file == null) return;

      final reader = web.FileReader();
      reader.readAsText(file);
      reader.onLoadEnd.listen((_) {
        final content = reader.result;
        if (content != null) {
          final text = (content as JSString).toDart;
          onFileLoaded(text, file.name, file.size);
        }
      });
    });
  } catch (_) {}
}

void downloadCsvWeb(String content, String filename) {
  try {
    final bytes = utf8.encode(content);
    final blob = web.Blob([bytes.toJS].toJS, web.BlobPropertyBag(type: 'text/csv;charset=utf-8'));
    final url = web.URL.createObjectURL(blob);
    final anchor = web.HTMLAnchorElement()
      ..href = url
      ..download = filename;
    anchor.click();
    web.URL.revokeObjectURL(url);
  } catch (_) {}
}
