// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logging/logging.dart';

import 'persistence/hive_settings_persistence.dart';
import 'persistence/settings_data.dart';
import 'persistence/settings_persistence.dart';

/// An class that holds settings like [musicOn],
/// and saves them to an injected persistence store.
class SettingsController {
  static final _log = Logger('SettingsController');

  final SettingsPersistence _store;

  late final Future<void> initialized;

  ValueNotifier<bool> audioOn = ValueNotifier(true);

  ValueNotifier<bool> soundsOn = ValueNotifier(true);

  ValueNotifier<bool> musicOn = ValueNotifier(true);

  ValueNotifier<double> sfxVolume = ValueNotifier(1.0);

  ValueNotifier<double> musicVolume = ValueNotifier(1.0);

  /// Creates a new instance of [SettingsController] backed by [store].
  ///
  /// By default, settings are persisted using [HiveSettingsPersistence].
  SettingsController({SettingsPersistence? store})
    : _store = store ?? HiveSettingsPersistence(
        box: Hive.box<SettingsData>('settings'),
      ) {
    initialized = _loadStateFromPersistence();
  }

  void toggleAudioOn() {
    final newValue = !audioOn.value;
    audioOn.value = newValue;
    
    if (!newValue) {
      soundsOn.value = false;
      musicOn.value = false;
      _store.saveAllSettings(audioOn: newValue, soundsOn: false, musicOn: false);
    } else {
      soundsOn.value = true;
      musicOn.value = true;
      _store.saveAllSettings(audioOn: newValue, soundsOn: true, musicOn: true);
    }
  }

  void toggleMusicOn() {
    musicOn.value = !musicOn.value;
    _store.saveMusicOn(musicOn.value);
  }

  void toggleSoundsOn() {
    soundsOn.value = !soundsOn.value;
    _store.saveSoundsOn(soundsOn.value);
  }

  void setSfxVolume(double value) {
    sfxVolume.value = value;
    _store.saveSfxVolume(value);
  }

  void setMusicVolume(double value) {
    musicVolume.value = value;
    _store.saveMusicVolume(value);
  }

  /// Asynchronously loads values from the injected persistence store.
  Future<void> _loadStateFromPersistence() async {
    final loadedValues = await Future.wait([
      _store.getAudioOn(defaultValue: true).then((value) {
        if (kIsWeb) {
          // On the web, sound can only start after user interaction, so
          // we start muted there on every game start.
          return audioOn.value = false;
        }
        // On other platforms, we can use the persisted value.
        return audioOn.value = value;
      }),
      _store
          .getSoundsOn(defaultValue: true)
          .then((value) => soundsOn.value = value),
      _store
          .getMusicOn(defaultValue: true)
          .then((value) => musicOn.value = value),
      _store.getSfxVolume(defaultValue: 1.0).then((value) => sfxVolume.value = value),
      _store.getMusicVolume(defaultValue: 1.0).then((value) => musicVolume.value = value),
    ]);

    _log.fine(() => 'Loaded settings: $loadedValues');
  }
}
