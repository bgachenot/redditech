import 'dart:math';
import 'package:intl/intl.dart' as intl;

class ExceptionLoginRandomString implements Exception {}

class ExceptionLoginUserRefused implements Exception {}

class ExceptionLoginInvalid implements Exception {}

const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
Random _rng = Random();

String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
    length, (_) => _chars.codeUnitAt(_rng.nextInt(_chars.length))));

String prettyNumber(int number) {
  String result = number.toString();
  if (number >= 1000 && number <= 9999) {
    number = number ~/ 100;
    var formatter = intl.NumberFormat('##0,0k');
    result = formatter.format(number);
  }
  if (number >= 10000 && number <= 99999) {
    number = number ~/ 1000;
    var formatter = intl.NumberFormat('##0,0k');
    result = formatter.format(number);
  }
  if (number >= 100000 && number <= 999999) {
    number = number ~/ 10000;
    var formatter = intl.NumberFormat('##0,0k');
    result = formatter.format(number);
  }
  if (number >= 1000000 && number <= 9999999) {
    number = number ~/ 100000;
    var formatter = intl.NumberFormat('##0,0m');
    result = formatter.format(number);
  }
  if (number >= 10000000 && number <= 99999999) {
    number = number ~/ 1000000;
    var formatter = intl.NumberFormat('##0,0m');
    result = formatter.format(number);
  }
  if (number >= 100000000 && number <= 999999999) {
    number = number ~/ 10000000;
    var formatter = intl.NumberFormat('##0,0m');
    result = formatter.format(number);
  }
  if (number >= 1000000000 && number <= 9999999999) {
    number = number ~/ 100000000;
    var formatter = intl.NumberFormat('##0,0m');
    result = formatter.format(number);
  }
  if (number >= 10000000000 && number <= 9999999999) {
    number = number ~/ 1000000000;
    var formatter = intl.NumberFormat('##0,0M');
    result = formatter.format(number);
  }
  return result;
}

String difference(double time, bool days, bool hours) {
  DateTime _accountCreatedSince =
      DateTime.fromMillisecondsSinceEpoch((time * 1000).toInt(), isUtc: true);
  if (days) {
    return DateTime.now().difference(_accountCreatedSince).inDays.toString();
  }
  if (hours) {
    return DateTime.now().difference(_accountCreatedSince).inHours.toString();
  }
  return "";
}
