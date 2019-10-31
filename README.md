# zip_code_jp

A dart package for Japan Post official zip code search and update.

Inspired by  [rinkei/jipcode](https://github.com/rinkei/jipcode).

## Installation

### 1. Depend on it

```
dependencies:
  zip_code_jp: ^1.0.0
```

### 2. Install it

with pub:

```
$ pub get
```

with Flutter:

```
$ flutter pub get
```

### 3. Import it

```
import 'package:zip_code_jp/zip_code_jp.dart';
```

## Usage

### Search

```
await ZipCodeJp.locate('1600022');
// => [{'zipcode': '1600022', 'prefecture': '東京都', 'city': '新宿区', 'town': '新宿'}]
```

### Update

日本郵便の郵便番号データを毎月アップデートします (予定)
最新のデータを利用したい場合は、パッケージのバージョンをアップデートしてください。

update package

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b new_feature_branch`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin new_feature_branch`)
5. Create new Pull Request