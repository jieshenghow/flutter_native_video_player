import 'flutter_native_video_player_platform_interface.dart';

class FlutterNativeVideoPlayer {
  bool _isPlaying = false, _isInitialised = false;

  bool get isPlaying => _isPlaying;

  bool get isInitialised => _isInitialised;

  Future<String?> getPlatformVersion() {
    return FlutterNativeVideoPlayerPlatform.instance.getPlatformVersion();
  }

  Future<void> initialise(String url) {
    return FlutterNativeVideoPlayerPlatform.instance.initialise(url).then((_) {
      _isInitialised = true;
    });
  }

  Future<void> play() {
    _isPlaying = true;
    return FlutterNativeVideoPlayerPlatform.instance.play();
  }

  Future<void> pause() {
    _isPlaying = false;
    return FlutterNativeVideoPlayerPlatform.instance.pause();
  }

  Future<void> seekTo(double position) {
    return FlutterNativeVideoPlayerPlatform.instance.seekTo(position);
  }

  Future<void> dispose() {
    return FlutterNativeVideoPlayerPlatform.instance.dispose();
  }

  Future<void> replay() {
    _isPlaying = true;
    return FlutterNativeVideoPlayerPlatform.instance.replay();
  }

  Stream<Map<String, dynamic>> get onProgressUpdate {
    return FlutterNativeVideoPlayerPlatform.instance.onProgressUpdate;
  }

  Stream<bool> get onPlayerStateUpdate {
    return FlutterNativeVideoPlayerPlatform.instance.onPlayerStateUpdate;
  }
}
