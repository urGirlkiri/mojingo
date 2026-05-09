# Grimoji


A game where you mix emojis to create new emojis!!

## Screenshots

<table>
  <tr>
    <td align="center">
      <img src="assets/screenshots/small.png" alt="Mobile Screenshot" width="250"/>
      <br/>
      <sub>Mobile</sub>
    </td>
    <td align="center">
      <img src="assets/screenshots/large.png" alt="Desktop Screenshot" width="400"/>
      <br/>
      <sub>Desktop</sub>
    </td>
  </tr>
</table>

## Setup

### Install Flutter

```bash
flutter doctor
```

### Install Dependencies

```bash
flutter pub get
```

### Sanity Check

```bash
flutter analyze
```


## How To Run


### Web


```bash
flutter run -d chrome
```

### Android

```bash
flutter run -d android
```

### iOS

```bash
flutter run -d ios
```

## Windows

```bash
flutter run -d windows
```

## Linux

```bash
flutter run -d linux
```

## macOS

```bash
flutter run -d macos
```

## Credits

- [Animated Emoji 💖](https://googlefonts.github.io/noto-emoji-animation/) for the emoji animations and SVG icons

- [Pixabay](https://pixabay.com/) for the sfx

- [Gemini](https://gemini.google.com/) for the music

- [Vecteezy](https://vecteezy.com/) for the background and pattern images

## Logging



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
