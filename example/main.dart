import 'package:zip_code_jp/zip_code_jp.dart';

main() async {
  var address = await ZipCodeJp.locate('1600022');
  print(address);

  var addressAndPrefectureCode =
      await ZipCodeJp.locate('1600022', opt: {'prefecture_code': true});
  print(addressAndPrefectureCode);
}
