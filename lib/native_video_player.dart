import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'ios_native_player.dart';
import 'android_native_player.dart';
import 'flutter_native_video_player.dart';
class NativeVideoPlayer extends StatelessWidget{
  const NativeVideoPlayer({super.key, required this.controller});

 final FlutterNativeVideoPlayer controller;

  @override
  Widget build(BuildContext context) {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return const IosNativePlayer();
      case TargetPlatform.android:
        return const AndroidNativePlayer();
      default:
        throw UnsupportedError("Unsupported platform view");
    }
  }

}
