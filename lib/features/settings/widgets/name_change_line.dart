// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:grimoji/features/settings/controller.dart';
import 'package:grimoji/features/settings/widgets/custom_name_dialog.dart';
import 'package:provider/provider.dart';

class NameChangeLine extends StatelessWidget {
  final String title;

  const NameChangeLine(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();

    return InkResponse(
      highlightShape: BoxShape.rectangle,
      onTap: () => showCustomNameDialog(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
            ),
            const Spacer(),
            ValueListenableBuilder(
              valueListenable: settings.playerName,
              builder: (context, name, child) => Text(
                '‘$name’',
                              style: Theme.of(context).textTheme.bodyMedium,

              ),
            ),
          ],
        ),
      ),
    );
  }
}
