package com.jieshenghow.flutter_native_video_player

import android.content.Context
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.view.View
import androidx.media3.common.MediaItem
import androidx.media3.common.PlaybackParameters
import androidx.media3.common.Player
import androidx.media3.common.Timeline
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.ui.PlayerView
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory


object ExoPlayerSingleton {
    private var exoPlayer: ExoPlayer? = null

    fun getInstance(context: Context): ExoPlayer {
        if (exoPlayer == null) {
            exoPlayer = ExoPlayer.Builder(context).build()
        }
        return exoPlayer!!
    }

    fun release() {
        exoPlayer?.release()
        exoPlayer = null
    }
}


/** FlutterNativeVideoPlayerPlugin */
class FlutterNativeVideoPlayerPlugin : FlutterPlugin, MethodCallHandler {
    companion object {
        var eventSink: EventChannel.EventSink? = null
        var playerEventSink: EventChannel.EventSink? = null
    }

    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private lateinit var eventChannel: EventChannel
    private lateinit var playerEventChannel: EventChannel
    private var isInitialised: Boolean = false


    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_native_video_player")
        channel.setMethodCallHandler(this)
        eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "flutter_native_video_player/progress")
        playerEventChannel =
            EventChannel(flutterPluginBinding.binaryMessenger, "flutter_native_video_player/player")
        eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                eventSink = events
            }

            override fun onCancel(arguments: Any?) {
                eventSink = null
            }
        })
        playerEventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                playerEventSink = events
            }

            override fun onCancel(arguments: Any?) {
                playerEventSink = null
            }
        })
        flutterPluginBinding.platformViewRegistry.registerViewFactory(
            "exoplayer_view", ExoPlayerViewFactory(flutterPluginBinding.binaryMessenger, context)
        )
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        val exoPlayer = ExoPlayerSingleton.getInstance(context)
        when (call.method) {
            "initialise" -> initialise(call, result, exoPlayer)
            "play" -> play(call, exoPlayer, result)
            "pause" -> pause(exoPlayer, result)
            "seekTo" -> seekTo(call, exoPlayer, result)
            "dispose" -> dispose(result)
            "resume" -> resume(exoPlayer, result)
            "isPlaying" -> isPlaying(result, exoPlayer)
            "replay" -> replay(call, exoPlayer, result)
            "isInitialised" -> result.success(isInitialised)
            "position" -> position(exoPlayer, result)
            "duration" -> duration(exoPlayer, result)
            else -> result.notImplemented()
        }
    }

    private fun initialise(call: MethodCall, result: Result, exoPlayer: ExoPlayer) {
        val url = call.argument<String>("url") ?: run {
            result.error("INVALID_ARGUMENT", "URL is required", null)
            return
        }
        val mediaItem = MediaItem.fromUri(Uri.parse(url))
        exoPlayer.setMediaItem(mediaItem)
        exoPlayer.prepare()
        isInitialised = true
        result.success(null)
    }

    private fun play(call: MethodCall, exoPlayer: ExoPlayer, result: Result) {
        exoPlayer.play()
        result.success(null)
    }

    private fun pause(exoPlayer: ExoPlayer, result: Result) {
        exoPlayer.pause()
        result.success(null)
    }

    private fun resume(exoPlayer: ExoPlayer, result: Result) {
        exoPlayer.play()
        result.success(null)
    }

    private fun replay(call: MethodCall, exoPlayer: ExoPlayer, result: Result) {
        exoPlayer.seekTo(0)
        exoPlayer.play()
    }

    private fun duration(exoPlayer: ExoPlayer, result: Result) {
        result.success(exoPlayer.duration)
    }

    private fun position(exoPlayer: ExoPlayer, result: Result) {
        result.success(exoPlayer.currentPosition)
    }

    private fun seekTo(call: MethodCall, exoPlayer: ExoPlayer, result: Result) {
        val position = when (val pos = call.argument<Any>("position")) {
            is Int -> pos.toLong()
            is Long -> pos
            else -> {
                result.error("INVALID_ARGUMENT", "Position is required and must be a number", null)
                return
            }
        }
        exoPlayer.seekTo(position)
        result.success(null)
    }

    private fun isPlaying(result: Result, exoPlayer: ExoPlayer) {
        result.success(exoPlayer.isPlaying)
    }

    private fun dispose(result: Result) {
        ExoPlayerSingleton.release()
        result.success(null)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
    }
}

class ExoPlayerViewFactory(private val messenger: BinaryMessenger, private val context: Context) :
    PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context?, viewId: Int, args: Any?): PlatformView {
        return ExoPlayerView(context ?: this.context, messenger, viewId, args as? Map<*, *>)
    }
}

class ExoPlayerView(
    private val context: Context, messenger: BinaryMessenger, id: Int, args: Map<*, *>?
) : PlatformView {
    private val playerView: PlayerView = PlayerView(context)
    private val exoPlayer: ExoPlayer = ExoPlayerSingleton.getInstance(context)
    private val handler: Handler = Handler(Looper.getMainLooper())
    private val updateInterval: Long = 1000

    private val progressRunnable: Runnable = object : Runnable {
        override fun run() {
            handler.postDelayed(this, updateInterval)
            sendProgressUpdate()
        }
    }

    init {
        playerView.player = exoPlayer
        playerView.useController = false

        exoPlayer.addListener(object : Player.Listener {
            override fun onPlaybackStateChanged(state: Int) {
                val stateString: String = when (state) {
                    Player.STATE_BUFFERING -> "BUFFERING"
                    Player.STATE_ENDED -> "ENDED"
                    Player.STATE_IDLE -> "IDLE"
                    Player.STATE_READY -> "READY"
                    else -> "UNKNOWN STATE"
                }
                if (state == Player.STATE_READY || state == Player.STATE_BUFFERING) {
                    handler.post(progressRunnable)
                } else {
                    handler.removeCallbacks(progressRunnable)
                }
            }

            override fun onIsPlayingChanged(isPlaying: Boolean) {
                sendProgressUpdate()
                if (isPlaying) {
                    handler.post(progressRunnable)
                } else {
                    handler.removeCallbacks(progressRunnable)
                }
            }

            override fun onPlaybackParametersChanged(playbackParameters: PlaybackParameters) {

            }

            override fun onTimelineChanged(timeline: Timeline, reason: Int) {
                sendProgressUpdate()
            }

            override fun onIsLoadingChanged(isLoading: Boolean) {
                sendProgressUpdate()
            }

            override fun onMediaItemTransition(mediaItem: MediaItem?, reason: Int) {
                super.onMediaItemTransition(mediaItem, reason)
            }
        })
    }


    private fun sendProgressUpdate() {
        val currentPosition = exoPlayer.currentPosition.toDouble()
        val bufferedPosition = exoPlayer.bufferedPosition.toDouble()
        val duration = exoPlayer.duration.toDouble()
        val isPlaying = exoPlayer.isPlaying

        val progressMap = mapOf(
            "currentPosition" to currentPosition,
            "bufferedPosition" to bufferedPosition,
            "duration" to duration
        )

        FlutterNativeVideoPlayerPlugin.eventSink?.success(progressMap)
        FlutterNativeVideoPlayerPlugin.playerEventSink?.success(isPlaying)
    }

    override fun getView(): View {
        return playerView
    }

    override fun dispose() {
        handler.removeCallbacks(progressRunnable)
        ExoPlayerSingleton.release()
    }
}

