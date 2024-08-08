import Flutter
import UIKit
import AVKit
import AVFoundation

class PlayerManager {
    static let shared = PlayerManager()
    
    var player: AVPlayer?
    var playerViewController: AVPlayerViewController?
    private var timeObserverToken: Any?
    
    private init() {
        // Private initialization to ensure just one instance is created.
    }
    
    func initialisePlayer(url: String) {
        let videoUrl = URL(string: url)!
        player = AVPlayer(url: videoUrl)
        playerViewController = AVPlayerViewController()
        playerViewController?.player = player
        playerViewController?.allowsPictureInPicturePlayback = true
        
        addPeriodicTimeObserver()
    }
    
    func play() {
        player?.play()
    }
    
    func pause() {
        player?.pause()
    }
    
    func seek(to position: Double) {
        let seekTime = CMTimeMakeWithSeconds(
            position / 1000,
            preferredTimescale: 1000
        )
        player?
            .seek(to: seekTime, toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] _ in
                self?.player?.play()
            }
    }
    
    private func addPeriodicTimeObserver() {
        guard let player = player else { return }
        
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 1.0, preferredTimescale: timeScale)
        
        timeObserverToken = player
            .addPeriodicTimeObserver(forInterval: time, queue: .main) { [weak self] (
                time
            ) in
                self?.notifyTimeChange()
            }

    }
    
    private func notifyTimeChange() {
        guard let player = player else { return }
        let currentPosition = player.currentTime().seconds * 1000
        let duration = (player.currentItem?.duration.seconds ?? 0) * 1000
        let bufferedTime = (player.currentItem?.loadedTimeRanges
            .map { $0.timeRangeValue }
            .map { $0.start.seconds + $0.duration.seconds }
            .max() ?? 0) * 1000
        
        FlutterNativeVideoPlayerPlugin.instance?
            .sendPlayerStateUpdate(
                currentPosition: currentPosition,
                duration: duration,
                bufferedPosition: bufferedTime
            )
    }
    
}

public class FlutterNativeVideoPlayerPlugin: NSObject, FlutterPlugin {
    
    static var instance: FlutterNativeVideoPlayerPlugin?
    private var eventSink: FlutterEventSink?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "flutter_native_video_player",
            binaryMessenger: registrar.messenger()
        )
        let instance = FlutterNativeVideoPlayerPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        
        let eventChannel = FlutterEventChannel(
            name: "flutter_native_video_player/progress",
            binaryMessenger: registrar.messenger()
        )
        eventChannel.setStreamHandler(instance)
        
        let factory = AVKitPlayerFactory(messenger: registrar.messenger())
        registrar.register(factory, withId: "avkit_player")
        
        self.instance = instance
    }

    public func handle(
        _ call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
            if let args = call.arguments as? [String: Any], let url = args["url"] as? String {
                PlayerManager.shared.initialisePlayer(url: url)
                presentPlayer()
                result(nil)
            } else {
                result(
                    FlutterError(
                        code: "INVALID_ARGUMENTS",
                        message: "URL is required",
                        details: nil
                    )
                )
            }
        case "play":
            PlayerManager.shared.play()
            result(nil)
        case "pause":
            PlayerManager.shared.pause()
            result(nil)
        case "seekTo":
            if let args = call.arguments as? [String: Any], let position = args["position"] as? Double {
                PlayerManager.shared.seek(to: position)
                result(nil)
            } else {
                result(
                    FlutterError(
                        code: "INVALID_ARGUMENTS",
                        message: "Position is required",
                        details: nil
                    )
                )
            }
        case "initialise":
            if let args = call.arguments as? [String: Any], let url = args["url"] as? String {
                PlayerManager.shared.initialisePlayer(url: url)
                result(nil)
            } else {
                result(
                    FlutterError(
                        code: "INVALID_ARGUMENTS",
                        message: "URL is required",
                        details: nil
                    )
                )
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func presentPlayer() {
        if let playerVC = PlayerManager.shared.playerViewController, let rootVC = UIApplication.shared.keyWindow?.rootViewController {
            rootVC.present(playerVC, animated: true, completion: {
                PlayerManager.shared.play()
            })
        }
    }
    
    func sendPlayerStateUpdate(
        currentPosition: Double,
        duration: Double,
        bufferedPosition: Double
    ){
        eventSink?([
            "currentPosition": currentPosition,
            "duration":duration,
            "bufferedPosition": bufferedPosition
        ])
    }
    
}

extension FlutterNativeVideoPlayerPlugin: FlutterStreamHandler {
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }
    
    
}

class AVKitPlayerFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger
    
    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }
                
    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> any FlutterPlatformView {
        return AVKitPlayer(
            frame: frame,
            viewId: viewId,
            args: args,
            messenger: messenger
        )
    }
    
    func createArgsCodec() -> any FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}

class AVKitPlayer: NSObject, FlutterPlatformView {
    private var _view: UIView
    
    init(
        frame: CGRect,
        viewId: Int64,
        args: Any?,
        messenger: FlutterBinaryMessenger
    ) {
        _view = UIView(frame: frame)
        super.init()
          
        if let playerVC = PlayerManager.shared.playerViewController {
            playerVC.view.frame = _view.bounds
            playerVC.showsPlaybackControls = false
            playerVC.allowsPictureInPicturePlayback = true
            _view.addSubview(playerVC.view)
        }
    }
        
    func view() -> UIView {
        return _view
    }
}
