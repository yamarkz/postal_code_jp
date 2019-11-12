# 📮postal_code_jp

[![pub package](https://img.shields.io/pub/v/postal_code_jp.svg)](https://pub.dev/packages/postal_code_jp)

[![Build Status](https://travis-ci.org/yamarkz/postal_code_jp.svg?branch=master)](https://travis-ci.org/yamarkz/postal_code_jp)

A dart package for Japan Post official postal code, a.k.a zip code, search and update.

Inspired by  [rinkei/jipcode](https://github.com/rinkei/jipcode).

## Installation

### 1. Depend on it

```
dependencies:
  postal_code_jp: ^1.0.0
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
import 'package:postal_code_jp/postal_code_jp.dart';
```

## Usage

### Search

```
await PostalCodeJp.locate('1600022');
// => [{'postal_code': '1600022', 'prefecture': '東京都', 'city': '新宿区', 'town': '新宿'}]
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
