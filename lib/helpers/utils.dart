import 'dart:convert';
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
  if (number >= 1000) {
    number = number ~/ 1000;
    var formatter = intl.NumberFormat('##0,0k');
    result = formatter.format(number);
    return result;
  }
  if (number >= 1000000) {
    number = number ~/ 1000000;
    var formatter = intl.NumberFormat('##0,0m');
    result = formatter.format(number);
    return result;
  }
  if (number >= 1000000000) {
    number = number ~/ 1000000000;
    var formatter = intl.NumberFormat('##0,0M');
    result = formatter.format(number);
    return result;
  }
  return result;
}