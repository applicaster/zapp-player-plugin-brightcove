package com.applicaster.player.plugins.brightcove

import android.net.Uri
import android.os.Bundle
import android.support.v7.app.AppCompatActivity
import android.view.View
import android.view.Window
import android.view.WindowManager
import com.applicaster.player.plugins.brightcove.AnalyticsAdapter.PlayerMode.FULLSCREEN
import com.applicaster.plugin_manager.playersmanager.Playable
import com.brightcove.player.event.EventType
import com.brightcove.player.view.BrightcoveVideoView

class BrightcovePlayerActivity : AppCompatActivity() {

  private lateinit var playable: Playable
  private lateinit var videoView: BrightcoveVideoView
  private lateinit var analyticsAdapter: AnalyticsAdapter

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)

    // setup window for fullscreen
    requestWindowFeature(Window.FEATURE_NO_TITLE)
    window.setFlags(
      WindowManager.LayoutParams.FLAG_FULLSCREEN,
      WindowManager.LayoutParams.FLAG_FULLSCREEN
    )
    // inject layout
    setContentView(R.layout.activity_brightcove_player)
    videoView = findViewById(R.id.video_view)
    videoView.eventEmitter.on(EventType.COMPLETED) { finish() }

    // initialize playable
    playable = intent.extras!!.getSerializable(BrightcovePlayerAdapter.KEY_PLAYABLE) as Playable
    videoView.setVideoURI(Uri.parse(playable.contentVideoURL))

    // initialize tools
    analyticsAdapter = MorpheusAnalyticsAdapter(videoView)
    analyticsAdapter.startTrack(playable, FULLSCREEN)
  }

  override fun onStart() {
    super.onStart()
    videoView.start()
  }

  override fun onDestroy() {
    super.onDestroy()
    analyticsAdapter.endTrack(playable, FULLSCREEN)
  }

  override fun onWindowFocusChanged(hasFocus: Boolean) {
    super.onWindowFocusChanged(hasFocus)
    if (hasFocus) {
      this.window
        .decorView.systemUiVisibility = (View.SYSTEM_UI_FLAG_LAYOUT_STABLE
          or View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
          or View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
          or View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
          or View.SYSTEM_UI_FLAG_FULLSCREEN
          or View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY)
    }
  }
}
