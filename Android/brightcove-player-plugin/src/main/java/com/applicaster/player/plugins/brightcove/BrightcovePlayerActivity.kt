package com.applicaster.player.plugins.brightcove

import android.app.Activity
import android.arch.lifecycle.Lifecycle
import android.arch.lifecycle.LifecycleObserver
import android.arch.lifecycle.LifecycleOwner
import android.arch.lifecycle.OnLifecycleEvent
import android.content.Context
import android.content.pm.ActivityInfo
import android.content.res.Configuration
import android.net.Uri
import android.os.Bundle
import android.support.v7.app.AppCompatActivity
import android.view.OrientationEventListener
import android.view.Surface
import android.view.WindowManager
import com.applicaster.player.plugins.brightcove.AnalyticsAdapter.PlayerMode.FULLSCREEN
import com.applicaster.plugin_manager.playersmanager.Playable
import com.brightcove.player.event.EventListener
import com.brightcove.player.event.EventType
import com.brightcove.player.view.BrightcoveVideoView

class BrightcovePlayerActivity : AppCompatActivity() {

  private lateinit var playable: Playable
  private lateinit var videoView: BrightcoveVideoView
  //
  private lateinit var orientationController: VideoOrientationController<AppCompatActivity>
  //
  private lateinit var analyticsAdapter: AnalyticsAdapter

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)

    // inject layout
    setContentView(R.layout.activity_brightcove_player)
    videoView = findViewById(R.id.video_view)
    videoView.eventEmitter.on(EventType.COMPLETED) { finish() }

    orientationController = VideoOrientationController(this, videoView)

    // initialize playable
    playable = intent.extras!!.getSerializable(BrightcovePlayerAdapter.KEY_PLAYABLE) as Playable
    videoView.setVideoURI(Uri.parse(playable.contentVideoURL))

    // initialize tools
    analyticsAdapter = MorpheusAnalyticsAdapter(videoView)
    analyticsAdapter.startTrack(playable, FULLSCREEN)
  }

  override fun onConfigurationChanged(newConfig: Configuration?) {
    super.onConfigurationChanged(newConfig)
    newConfig?.orientation?.also { orientationController.onNewConfigOrientation(it) }
  }

  override fun onStart() {
    super.onStart()
    videoView.start()
  }

  override fun onDestroy() {
    super.onDestroy()
    analyticsAdapter.endTrack(playable, FULLSCREEN)
  }

}

/**
 * FullScreen & Orientation rotation controller to sync video view, window params and screen rotation.
 */
private class VideoOrientationController<T>(
  private val activity: T,
  private val videoView: BrightcoveVideoView,
  private val sensorEpsilon: Int = 10
) : OrientationEventListener(activity), LifecycleObserver
    where T : Activity, T : LifecycleOwner {

  private var fullscreenListenerEnabled = true
  private var fullscreenTriggered = false
  private var sensorEnabled = false

  init {
    initFullScreenClickListener()
    activity.lifecycle.addObserver(this)
  }

  @OnLifecycleEvent(Lifecycle.Event.ON_START)
  fun restore() {
    if (sensorEnabled) enable()
  }

  @OnLifecycleEvent(Lifecycle.Event.ON_STOP)
  fun dispose() {
    disable()
  }

  private fun initFullScreenClickListener() {
    val fullScreenListener = EventListener {
      if (fullscreenListenerEnabled) {
        fullscreenTriggered = true
        setOppositeOrientation()
      } else {
        fullscreenListenerEnabled = true
      }
    }
    videoView.eventEmitter.on(EventType.DID_ENTER_FULL_SCREEN, fullScreenListener)
    videoView.eventEmitter.on(EventType.DID_EXIT_FULL_SCREEN, fullScreenListener)
  }

  override fun onOrientationChanged(orientation: Int) {
    if (
      epsilonCheck(orientation, leftLandscape, sensorEpsilon) ||
      epsilonCheck(orientation, rightLandscape, sensorEpsilon)
    ) {
      activity.requestedOrientation = ActivityInfo.SCREEN_ORIENTATION_UNSPECIFIED
      sensorEnabled = false
      this.disable()
    }
  }

  fun onNewConfigOrientation(orientation: Int) {
    if (fullscreenTriggered) {
      fullscreenTriggered = false
    } else {
      fullscreenListenerEnabled = false
      when (orientation) {
        Configuration.ORIENTATION_PORTRAIT -> videoView.eventEmitter.emit(EventType.EXIT_FULL_SCREEN)
        Configuration.ORIENTATION_LANDSCAPE -> videoView.eventEmitter.emit(EventType.ENTER_FULL_SCREEN)
      }
    }
  }

  private fun setOppositeOrientation() {
    val rotation = (activity.getSystemService(Context.WINDOW_SERVICE) as WindowManager)
      .defaultDisplay
      .rotation
    activity.requestedOrientation = when (rotation) {
      Surface.ROTATION_0, Surface.ROTATION_180 -> ActivityInfo.SCREEN_ORIENTATION_USER_LANDSCAPE
      Surface.ROTATION_90, Surface.ROTATION_270 -> ActivityInfo.SCREEN_ORIENTATION_USER_PORTRAIT
      else -> throw IllegalArgumentException("rotation is not supported")
    }
    sensorEnabled = true
    this.enable()
  }

  private fun epsilonCheck(a: Int, b: Int, epsilon: Int): Boolean =
    Math.abs(a - b) < epsilon

  companion object {
    private const val leftLandscape = 90
    private const val rightLandscape = 270
  }

}
