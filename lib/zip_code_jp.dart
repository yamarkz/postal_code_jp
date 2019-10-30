library zip_code_jp;

import 'dart:convert';
import 'dart:io';

import 'package:yaml/yaml.dart';

class ZipCodeJp {
  static final zipCodePath = '../data/latest';
  static final prefectureCode =
      loadYaml(File('../data/prefecture_code.yml').readAsStringSync());
  static final zipCodeRegExp = RegExp('\d{7}');
  static Future<List<Map<String, dynamic>>> locate(zipCode, {opt}) async {
    if (zipCodeRegExp.hasMatch(zipCode)) {
      throw ArgumentError('The post code must be 7 character');
    }

    final file = File("$zipCodePath/${zipCode.substring(0, 3)}.csv");
    if (file == null) return [];

    final lines =
        await file.openRead().transform(utf8.decoder).transform(LineSplitter());

    final fields = List<List<String>>();
    await for (var line in lines) {
      fields.add(line.split(','));
    }

    var addressesArray = fields.where((address) => address[0] == zipCode);

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
      'zipcode': addressParam[0],
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
