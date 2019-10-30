# zip_code_jp

## Installation

### 1. Depend on it

```
dependencies:
  zip_code_jp: ^1.0.0
```

### Install it

with pub:

```
$ pub get
```

with Flutter:

```
$ flutter pub get
```

3. Import it

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

update package
