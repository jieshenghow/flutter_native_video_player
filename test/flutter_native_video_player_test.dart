import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_native_video_player/flutter_native_video_player.dart';
import 'package:flutter_native_video_player/flutter_native_video_player_platform_interface.dart';
import 'package:flutter_native_video_player/flutter_native_video_player_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterNativeVideoPlayerPlatform
    with MockPlatformInterfaceMixin
    implements FlutterNativeVideoPlayerPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterNativeVideoPlayerPlatform initialPlatform = FlutterNativeVideoPlayerPlatform.instance;

  test('$MethodChannelFlutterNativeVideoPlayer is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterNativeVideoPlayer>());
  });

  test('getPlatformVersion', () async {
    FlutterNativeVideoPlayer flutterNativeVideoPlayerPlugin = FlutterNativeVideoPlayer();
    MockFlutterNativeVideoPlayerPlatform fakePlatform = MockFlutterNativeVideoPlayerPlatform();
    FlutterNativeVideoPlayerPlatform.instance = fakePlatform;

    expect(await flutterNativeVideoPlayerPlugin.getPlatformVersion(), '42');
  });
}
