# Grimoji


A game where you mix emojis to create new emojis!!

<img 
  src="assets/screenshots/mockup.png" 
  alt="Desktop Screenshot"
  style="max-width: 800px; max-height: 800px; object-fit: contain; border-radius: 12px;"
/>

## Setup

### Env Var

[See the example file](.env.example)

> Copy that fil and rename it to `.env` 

> Then enter your own values

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

## Tools

### Generating Emoji Visuals

> Run : `dart run tool/generate_emoji_icons.dart`

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
