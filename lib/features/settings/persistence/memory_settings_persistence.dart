// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'settings_persistence.dart';

/// An in-memory implementation of [SettingsPersistence].
/// Useful for testing.
class MemoryOnlySettingsPersistence implements SettingsPersistence {
  bool musicOn = true;

  bool soundsOn = true;

  bool audioOn = true;

  double sfxVolume = 1.0;

  double musicVolume = 1.0;

  @override
  Future<bool> getAudioOn({required bool defaultValue}) async => audioOn;

  @override
  Future<bool> getMusicOn({required bool defaultValue}) async => musicOn;

  @override
  Future<bool> getSoundsOn({required bool defaultValue}) async => soundsOn;

  @override
  Future<void> saveAudioOn(bool value) async => audioOn = value;

  @override
  Future<void> saveMusicOn(bool value) async => musicOn = value;

  @override
  Future<void> saveSoundsOn(bool value) async => soundsOn = value;

  @override
  Future<double> getSfxVolume({required double defaultValue}) async => sfxVolume;

  @override
  Future<double> getMusicVolume({required double defaultValue}) async => musicVolume;

  @override
  Future<void> saveSfxVolume(double value) async => sfxVolume = value;

  @override
  Future<void> saveMusicVolume(double value) async => musicVolume = value;
}
