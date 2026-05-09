# Grimoji


A game where you mix emojis to create new emojis!!

## Screenshots

<div style="display: flex; gap: 16px; flex-wrap: wrap; align-items: stretch;">

  <div style="flex: 1; min-width: 250px; text-align: center;">
    <img 
      src="assets/screenshots/small.png" 
      alt="Mobile Screenshot"
      style="width: 100%; height: auto; max-width: 250px; border-radius: 12px;"
    />
    <br/>
    <sub>Mobile</sub>
  </div>

  <div style="flex: 2; min-width: 300px; text-align: center; display: flex; flex-direction: column;">
    <div style="flex: 1; display: flex; align-items: center; justify-content: center;">
      <img 
        src="assets/screenshots/large.png" 
        alt="Desktop Screenshot"
        style="max-width: 100%; max-height: 100%; object-fit: contain; border-radius: 12px;"
      />
    </div>
    <sub>Desktop</sub>
  </div>

</div>

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
