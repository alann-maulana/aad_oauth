bool logEnabled = false;

void logPrintWrapped(String text, {String tag = 'AAD'}) {
  if (!logEnabled) return;

  if (tag != null) {
    text = '$tag: $text';
  }

  final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
  pattern.allMatches(text).forEach((match) => print(match.group(0)));
}