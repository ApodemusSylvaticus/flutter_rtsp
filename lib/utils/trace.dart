/// Timestamped diagnostic log for the Connect flow.
///
/// Every line starts with `[TRACE hh:mm:ss.mmm TAG]`, so the device log can
/// be filtered down to these. The iOS side prints the same kind of lines
/// from ios/Runner/DeviceWifi.swift, prefixed `[TRACE-iOS]` (NSLog adds the
/// timestamp there), so one Connect attempt reads as a single timeline.
void trace(String tag, String message) {
  final t = DateTime.now();
  String two(int v) => v.toString().padLeft(2, '0');
  final stamp = '${two(t.hour)}:${two(t.minute)}:${two(t.second)}.'
      '${t.millisecond.toString().padLeft(3, '0')}';
  // ignore: avoid_print
  print('[TRACE $stamp $tag] $message');
}
