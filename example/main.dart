import 'package:postal_code_jp/postal_code_jp.dart';

main() async {
  var address = await PostalCodeJp.locate('1600022');
  print(address);

  var addressAndPrefectureCode =
      await PostalCodeJp.locate('1600022', opt: {'prefecture_code': true});
  print(addressAndPrefectureCode);
}
