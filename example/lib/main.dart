import 'package:flutter/material.dart';
import 'package:flutter_native_video_player/flutter_native_video_player.dart';
import 'package:flutter_native_video_player/native_video_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _controller = FlutterNativeVideoPlayer();

  @override
  void initState() {
    super.initState();
    _controller
        .initialise(
            "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")
        .then((_) {
      setState(() {
        _controller.play();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: NativeVideoPlayer(
          controller: _controller,
        ),
      ),
    );
  }
}
