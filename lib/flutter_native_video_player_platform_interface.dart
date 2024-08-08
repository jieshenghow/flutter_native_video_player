import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_native_video_player_method_channel.dart';

abstract class FlutterNativeVideoPlayerPlatform extends PlatformInterface {
  /// Constructs a FlutterNativeVideoPlayerPlatform.
  FlutterNativeVideoPlayerPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterNativeVideoPlayerPlatform _instance =
      MethodChannelFlutterNativeVideoPlayer();

  /// The default instance of [FlutterNativeVideoPlayerPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterNativeVideoPlayer].
  static FlutterNativeVideoPlayerPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterNativeVideoPlayerPlatform] when
  /// they register themselves.
  static set instance(FlutterNativeVideoPlayerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<void> initialise(String url) {
    throw UnimplementedError("Initialise() has not been implemented.");
  }

  Future<void> play() {
    throw UnimplementedError("play() has not been implemented.");
  }

  Future<void> pause() {
    throw UnimplementedError("pause() has not been implemented");
  }

  Future<void> seekTo(double position) {
    throw UnimplementedError("seekTo() has not been implemented.");
  }

  Future<int> get position {
    throw UnimplementedError("position() has not been implemented");
  }

  Future<int> get duration {
    throw UnimplementedError("duration() has not been implemented");
  }

  Future<void> dispose() {
    throw UnimplementedError("dispose() has not been implemented");
  }

  Future<bool> get isPlaying {
    throw UnimplementedError("isPlaying() has not been implemented");
  }

  Future<void> replay() {
    throw UnimplementedError("replay() has not been implemented");
  }

  Stream<Map<String, dynamic>> get onProgressUpdate {
    throw UnimplementedError("onProgressUpdate() has not been implemented");
  }

  Stream<bool> get onPlayerStateUpdate {
    throw UnimplementedError("playerStateUpdate has not been implemented");
  }

  Future<bool> get isInitialised {
    throw UnimplementedError("isInitialised() has not been implemented");
  }
}
