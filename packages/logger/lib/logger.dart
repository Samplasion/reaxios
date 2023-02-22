library logger;

import 'package:colorize/colorize.dart';

class Logger {
  static final Logger instance = Logger();

  static d(String data) => instance.debug(data);
  debug(String data) {
    _print("DBG", data, Styles.CYAN);
  }

  static w(String data) => instance.warn(data);
  warn(String data) {
    _print("DBG", data, Styles.YELLOW);
  }

  static e(String data) => instance.error(data);
  error(String data) {
    _print("DBG", data, Styles.RED);
  }

  _print(String level, String data, Styles textColor) {
    final str = Colorize(data);
    str.apply(textColor);
    print("${Colorize("[$level]").apply(textColor).dark()} $str");
  }
}
