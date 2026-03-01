class StreamConfig {
  final String streamUrl;
  final String commandUrl;
  final String tcpCommandUrl;
  final bool shouldRunStreamView;

  StreamConfig({
    required this.streamUrl,
    required this.commandUrl,
    required this.tcpCommandUrl,
    required this.shouldRunStreamView,
  });
}
