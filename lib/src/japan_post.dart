import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';

class JapanPost {
  static final latestPostalCodePath = 'data/latest';
  static final previousPostalCodePath = 'data/previous';
  static final postalCodeUrls = {
    'general':
        'https://www.post.japanpost.jp/zipcode/dl/kogaki/zip/ken_all.zip',
    'company':
        'https://www.post.japanpost.jp/zipcode/dl/jigyosyo/zip/jigyosyo.zip',
  };

  static final postalCodeFiles = {
    'general': 'KEN_ALL.CSV',
    'company': 'JIGYOSYO.CSV',
  };

  static Future<void> update() async {
    await downloadAll();
    await importAll();

    await File('data/current_month')
        .writeAsString(DateFormat.yM().format(DateTime.now()));
  }

  static Future<void> downloadAll() async {
    await Future.forEach(postalCodeUrls.entries, (MapEntry<String,String>entry) async {
      final _downloadData = <int>[];
      final request = await HttpClient().getUrl(Uri.parse(entry.value));
      final response = await request.close();
      response.listen((d) => _downloadData.addAll(d), onDone: () {
        File("data/${entry.key}.zip").writeAsBytes(_downloadData);
      });
      print("download ${entry.key} done");
    });
    print('download All done');
  }

  static Future<void> importAll() async {
    try {
      final directory = Directory(latestPostalCodePath);
      if (await directory.exists()) {
        await directory.rename(previousPostalCodePath);
      }
      await Directory(latestPostalCodePath).create();

      final generalPostalCodes = await _unpack('general');
      _import(generalPostalCodes, _generalFormat);

      final companyPostalCodes = await _unpack('company');
      _import(companyPostalCodes, _companyFormat);

      Directory(previousPostalCodePath).deleteSync(recursive: true);
    } catch (e) {
      Directory(latestPostalCodePath).deleteSync(recursive: true);
      final directory = Directory(previousPostalCodePath);
      if (await directory.exists()) {
        await directory.rename(latestPostalCodePath);
      }
      print(e);
    }
  }

  static Future<String> _unpack(String type) async {
    final file = File('data/$type.zip');
    if (!file.existsSync()) {
      await downloadAll();
    }
    final archive = ZipDecoder().decodeBytes(file.readAsBytesSync());
    File('data/$type.csv')
      ..createSync(recursive: true)
      ..writeAsBytesSync(archive.findFile(postalCodeFiles[type]!)!.content);
    final result = await Process.run(
        'iconv', ['-f', 'Shift_JIS', '-t', 'utf8', 'data/$type.csv']);
    return result.stdout;
  }

  static void _import(String postalCodes, Function format) {
    var duplicatedRow = false;
    final listData = CsvToListConverter().convert(postalCodes);
    for (dynamic line in listData) {
      if (7 >= line.length) continue;
      var address = format(line);
      final town = address[3];
      if (duplicatedRow) {
        if (town.endsWith('）')) {
          duplicatedRow = false;
        }
        continue;
      } else {
        if (town.contains('（') && !town.contains('）')) {
          duplicatedRow = true;
        }
      }

      if (!town.contains('私書箱')) {
        address[3] = town.replaceAll('以下に掲載がない場合', '');
      }

      if (town.contains('の次に番地がくる場合') || town.contains('一円')) {
        address[3] = null;
      }

      if (!town.contains('私書箱') && town.contains(RegExp('（.*?）'))) {
        address[3] = town.replaceAll(RegExp('（.*?）'), '');
      }

      final filePath =
          "$latestPostalCodePath/${address[0].substring(0, 3)}.csv";
      File(filePath)
          .writeAsStringSync("${address.join(',')}\n", mode: FileMode.append);
    }
  }

  static List<dynamic> _generalFormat(dynamic values) {
    return [values[2], values[6], values[7], values[8]];
  }

  static List<dynamic> _companyFormat(dynamic values) {
    return [values[7], values[3], values[4], values[5] + values[6]];
  }
}
