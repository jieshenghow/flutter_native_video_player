import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_native_video_player_platform_interface.dart';

/// An implementation of [FlutterNativeVideoPlayerPlatform] that uses method channels.
class MethodChannelFlutterNativeVideoPlayer
    extends FlutterNativeVideoPlayerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_native_video_player');
  final EventChannel _progressEventChannel =
      const EventChannel('flutter_native_video_player/progress');
  final EventChannel _playerEventChannel =
      const EventChannel('flutter_native_video_player/player');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<void> initialise(String url) async {
    await methodChannel.invokeMethod("initialise", {"url": url});
  }

  @override
  Future<void> play() async {
    await methodChannel.invokeMethod("play");
  }

  @override
  Future<void> pause() async {
    await methodChannel.invokeMethod("pause");
  }

  @override
  Future<void> seekTo(double position) async {
    await methodChannel.invokeMethod("seekTo", {"position": position});
  }

  @override
  Future<void> dispose() async {
    await methodChannel.invokeMethod("dispose");
  }

  @override
  Future<bool> get isPlaying async {
    try {
      final bool isPlaying = await methodChannel.invokeMethod('isPlaying');
      return isPlaying;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<int> get position async {
    try {
      final int position = await methodChannel.invokeMethod("position");
      return position;
    } catch (e) {
      return 0;
    }
  }

  @override
  Future<int> get duration async {
    try {
      final int duration = await methodChannel.invokeMethod("duration");
      return duration;
    } catch (e) {
      return 0;
    }
  }

  @override
  Future<void> replay() async {
    await methodChannel.invokeMethod("replay");
  }

  @override
  Stream<Map<String, dynamic>> get onProgressUpdate {
    return _progressEventChannel.receiveBroadcastStream().map((event) {
      return Map<String, dynamic>.from(event);
    });
  }

  @override
  Stream<bool> get onPlayerStateUpdate {
    return _playerEventChannel
        .receiveBroadcastStream()
        .map((event) => event as bool);
  }

  @override
  Future<bool> get isInitialised async {
    final bool isInitialised =
        await methodChannel.invokeMethod("isInitialised");
    return isInitialised;
  }
}
