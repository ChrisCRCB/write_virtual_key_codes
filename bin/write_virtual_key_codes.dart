// ignore_for_file: avoid_print
import 'package:dio/dio.dart';
import 'package:html/parser.dart';
import 'package:recase/recase.dart';

/// The number key regular expression.
final numberKeyRegExp = RegExp(r'^[0-9]Key$');

/// The letter key regular expression.
final letterKeyRegExp = RegExp(r'^[a-z]Key$');

/// The URL to get key codes from.
const url =
    'https://learn.microsoft.com/en-us/windows/win32/inputdev/virtual-key-codes';

Future<void> main() async {
  final dio = Dio();
  final response = await dio.get<String>(url);
  final document = parse(response.data);
  final table = document.getElementsByTagName('table').first;
  print(
    '// ignore_for_file: constant_identifier_names, lines_longer_than_80_chars',
  );
  for (final tr in table.getElementsByTagName('tr')) {
    final cells = tr.getElementsByTagName('td');
    if (cells.length == 3) {
      final vk = cells.first.text;
      final hex = cells[1].text;
      final description = cells.last.text;
      if ([
        'Unassigned',
        'Reserved',
        'OEM specific',
      ].contains(description)) {
        continue;
      }
      var name = vk.isEmpty || vk == '-' ? description.camelCase : vk;
      if (numberKeyRegExp.firstMatch(name) != null) {
        name = 'digit${name[0]}';
      } else if (letterKeyRegExp.firstMatch(name) != null) {
        name = 'letter${name[0].toUpperCase()}';
      } else if (name.startsWith('VK_')) {
        name = name.substring(3).toLowerCase();
      }
      if ([
        'final',
        'return',
      ].contains(name)) {
        name = '${name}_';
      }
      print('\n/// $description');
      print('const $name = $hex;');
    }
  }
}
