library postal_code_jp;

import 'dart:convert';
import 'dart:io';

import 'package:yaml/yaml.dart';

class PostalCodeJp {
  static final latestPostalCodePath = 'data/latest';
  static final prefectureCode =
      loadYaml(File('data/prefecture_code.yml').readAsStringSync());
  static final postalCodeRegExp = RegExp('\d{7}');

  static Future<List<Map<String, dynamic>>> locate(postalCode, {opt}) async {
    if (postalCodeRegExp.hasMatch(postalCode)) {
      throw ArgumentError('The post code must be 7 character');
    }

    final file =
        File("$latestPostalCodePath/${postalCode.substring(0, 3)}.csv");
    if (!file.existsSync()) {
      return [];
    }

    final lines =
        file.openRead().transform(utf8.decoder).transform(LineSplitter());

    final fields = <List<String>>[];
    await for (var line in lines) {
      fields.add(line.split(','));
    }

    var addressesArray = fields.where((address) => address[0] == postalCode);

    if (opt == null) {
      return addressesArray
          .map((addressParam) => basicAddressFrom(addressParam))
          .toList();
    } else {
      return addressesArray
          .map((addressParam) =>
              extendedAddressFrom(addressParam, opt: {'prefecture_code': true}))
          .toList();
    }
  }

  static Map<String, dynamic> basicAddressFrom(addressParam) {
    return {
      'postal_code': addressParam[0],
      'prefecture': addressParam[1],
      'city': addressParam[2],
      'town': addressParam[3],
    };
  }

  static Map<String, dynamic> extendedAddressFrom(addressParam, {opt}) {
    Map<String, dynamic> address = basicAddressFrom(addressParam);
    if (opt.containsKey('prefecture_code')) {
      address['prefecture_code'] = prefectureCode.keys
          .firstWhere((k) => prefectureCode[k] == addressParam[1]);
    }
    return address;
  }
}
