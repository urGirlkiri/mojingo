# Mojingo


A game where you mix emojis to create new emojis!!


## How To Play


### Web


```bash
flutter run -d chrome
```

### Android

```bash
flutter run -d android
```


## Logging

The template uses the [`logging`](https://pub.dev/packages/logging) package
to log messages to the console. This makes it very easy to log messages
from anywhere with something like the following:

```dart
import 'package:logging/logging.dart';

final _log = Logger('Foo');

void foo() {
  _log.info('Hello, world!');
}
```

This will show up in the console as:

```text
[Foo] Hello, world!
```

When using Flutter DevTools, all the metadata of the log message is preserved, 
so you can filter by logger name, log level, and so on.
