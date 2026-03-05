// Copyright 2024 Andy.Zhao
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:io';

import 'package:flutter/services.dart';

Future<void> setScreenLandscape({
  List<DeviceOrientation> orientations = const [
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
  ],
}) async {
  if (Platform.isAndroid) {
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      overlays: <SystemUiOverlay>[SystemUiOverlay.bottom],
    );
  }
  await SystemChrome.setPreferredOrientations(orientations);
  await Future.delayed(const Duration(milliseconds: 150));
}

Future<void> setScreenPortrait() async {
  if (Platform.isAndroid) {
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
    );
  }
  await SystemChrome.setPreferredOrientations(
    <DeviceOrientation>[
      DeviceOrientation.portraitUp,
      // DeviceOrientation.portraitDown
    ],
  );
}
