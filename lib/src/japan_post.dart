import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';

class JapanPost {
  static final zipCodePath = '../../data/latest';
  static final zipCodeUrls = {
    'general':
        'https://www.post.japanpost.jp/zipcode/dl/kogaki/zip/ken_all.zip',
    'company':
        'https://www.post.japanpost.jp/zipcode/dl/jigyosyo/zip/jigyosyo.zip',
  };

  static final zipCodeFiles = {
    'general': 'KEN_ALL.CSV',
    'company': 'JIGYOSYO.CSV',
  };

  static void update() async {
    downloadAll();
    importAll();

    await File('../../data/current_month')
        .writeAsString(DateFormat.yM().format(DateTime.now()));
  }

  static void downloadAll() async {
    await Future.forEach(zipCodeUrls.entries, (entry) async {
      final _downloadData = List<int>();
      final request = await HttpClient().getUrl(Uri.parse(entry.value));
      final response = await request.close();
      response.listen((d) => _downloadData.addAll(d), onDone: () {
        File("../../data/${entry.key}.zip").writeAsBytes(_downloadData);
      });
      print("download ${entry.key} done");
    });
    print('download All done');
  }

  static void importAll() async {
    try {
      final directory = Directory(zipCodePath);
      if (await directory.exists()) {
        await directory.rename('../../data/previous');
      }
      await Directory(zipCodePath).create();

      final generalZipCodes = await _unpack('general');
      _import(generalZipCodes, _generalFormat);

      final companyZipCodes = await _unpack('company');
      _import(companyZipCodes, _companyFormat);

      Directory('../../data/previous').deleteSync(recursive: true);
    } catch (e) {
      Directory(zipCodePath).deleteSync(recursive: true);
      final directory = Directory('../../data/previous');
      if (await directory.exists()) {
        await directory.rename(zipCodePath);
      }
      print(e);
    }
  }

  static Future<String> _unpack(String type) async {
    final file = File('../../data/$type.zip');
    if (file == null) downloadAll();
    final archive = ZipDecoder().decodeBytes(file.readAsBytesSync());
    File('../../data/$type.csv')
      ..createSync(recursive: true)
      ..writeAsBytesSync(archive.findFile(zipCodeFiles[type]).content);
    final result = await Process.run(
        'iconv', ['-f', 'Shift_JIS', '-t', 'utf8', '../../data/$type.csv']);
    return result.stdout;
  }

  static void _import(String zipCodes, Function format) {
    var duplicatedRow = false;
    final listData = CsvToListConverter().convert(zipCodes);
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

      final filePath = "$zipCodePath/${address[0].substring(0, 3)}.csv";
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
