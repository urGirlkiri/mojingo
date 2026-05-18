// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

List<String> soundTypeToFilename(SfxType type) => switch (type) {
  SfxType.buttonTap => const [
    'whirl_test_tube.mp3'
  ],
  SfxType.congrats => const [
    'congrats.mp3' 
  ],
  SfxType.fail => const [
    'fail.mp3'
  ]
};

double soundTypeToVolume(SfxType type) {
  switch (type) {
    case SfxType.buttonTap:
    case SfxType.congrats:
    case SfxType.fail:
      return 1.0;
  }
}

enum SfxType { buttonTap, congrats, fail }