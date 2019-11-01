import 'dart:io';

import 'package:postal_code_jp/postal_code_jp.dart';
import 'package:test/test.dart';

void main() {
  setUp(() async {
    File('${PostalCodeJp.latestPostalCodePath}/000.csv').writeAsStringSync(
        "0000001,HOGE県,hoge市,ほげ\n0000001,FUGA県,fuga市,ふが\n0000002,PIYO県,piyo市,ぴよ");
  });

  tearDown(() async {
    File('${PostalCodeJp.latestPostalCodePath}/000.csv').delete();
  });

  group('test PostalCodeJp', () {
    test('.locate normally', () async {
      final address = await PostalCodeJp.locate('0000001');
      expect(
        address,
        equals([
          {
            'postal_code': '0000001',
            'prefecture': 'HOGE県',
            'city': 'hoge市',
            'town': 'ほげ'
          },
          {
            'postal_code': '0000001',
            'prefecture': 'FUGA県',
            'city': 'fuga市',
            'town': 'ふが'
          }
        ]),
      );
    });

    test('.locate not exist code', () async {
      final address = await PostalCodeJp.locate('0000000');
      expect(address, []);
    });

    test('.locate use opt parameter', () async {
      final address =
          await PostalCodeJp.locate('1000000', opt: {'prefecture_code': true});
      expect(
        address,
        [
          {
            'postal_code': '1000000',
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
