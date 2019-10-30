import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:zip_code_jp/zip_code_jp.dart';

void main() {
  setUp(() async {
    File('${ZipCodeJp.zipCodePath}/000.csv').writeAsStringSync(
        "0000001,HOGE県,hoge市,ほげ\n0000001,FUGA県,fuga市,ふが\n0000002,PIYO県,piyo市,ぴよ");
  });

  tearDown(() async {
    File('${ZipCodeJp.zipCodePath}/000.csv').delete();
  });

  group('test ZipCodeJp', () {
    test('.locate normally', () async {
      final address = await ZipCodeJp.locate('0000001');
      expect(
        address,
        equals([
          {
            'zipcode': '0000001',
            'prefecture': 'HOGE県',
            'city': 'hoge市',
            'town': 'ほげ'
          },
          {
            'zipcode': '0000001',
            'prefecture': 'FUGA県',
            'city': 'fuga市',
            'town': 'ふが'
          }
        ]),
      );
    });

    test('.locate not exist code', () async {
      final address = await ZipCodeJp.locate('0000000');
      expect(address, []);
    });

    test('.locate use opt parameter', () async {
      final address =
          await ZipCodeJp.locate('1000000', opt: {'prefecture_code': true});
      expect(
        address,
        [
          {
            'zipcode': '1000000',
            'prefecture': '東京都',
            'city': '千代田区',
            'town': '',
            'prefecture_code': 13,
          }
        ],
      );
    });
  });
}
