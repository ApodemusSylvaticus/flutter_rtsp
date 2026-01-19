class TcpAddress {
  final String? ip;
  final String? port;
  final String? path;

  TcpAddress({this.ip, this.port, this.path});

  factory TcpAddress.parse(String input) {
    final regex =
        RegExp(r'^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})(?::(\d+))?(.*)$');
    final match = regex.firstMatch(input);

    if (match != null) {
      return TcpAddress(
        ip: match.group(1),
        port: match.group(2),
        path: match.group(3),
      );
    }
    return TcpAddress();
  }
}
