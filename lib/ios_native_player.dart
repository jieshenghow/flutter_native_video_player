import 'package:flutter/material.dart';

class IosNativePlayer extends StatelessWidget {
  const IosNativePlayer({super.key});

  static const _iosViewType = "avkit_player";

  @override
  Widget build(BuildContext context) {
    return const AspectRatio(
        aspectRatio: 16 / 9,
        child: UiKitView(
          viewType: _iosViewType,
        ));
  }
}
