import 'dart:convert';
import 'dart:math';

class ExceptionLoginRandomString implements Exception {}
class ExceptionLoginUserRefused implements Exception {}
class ExceptionLoginInvalid implements Exception {}

const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
Random _rng = Random();

String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
    length, (_) => _chars.codeUnitAt(_rng.nextInt(_chars.length))));
