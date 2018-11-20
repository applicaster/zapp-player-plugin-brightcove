package com.applicaster.player.plugins.brightcove

import android.net.Uri
import android.os.Bundle
import android.support.v7.app.AppCompatActivity
import com.applicaster.player.plugins.brightcove.AnalyticsAdapter.PlayerMode.FULLSCREEN
import com.applicaster.plugin_manager.playersmanager.Playable
import com.brightcove.player.event.EventType
import com.brightcove.player.view.BrightcoveVideoView

class BrightcovePlayerActivity : AppCompatActivity() {

  private lateinit var playable: Playable
  private lateinit var videoView: BrightcoveVideoView
  //
  private lateinit var analyticsAdapter: AnalyticsAdapter

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)

    // inject layout
    setContentView(R.layout.activity_brightcove_player)
    videoView = findViewById(R.id.video_view)
    videoView.eventEmitter.on(EventType.COMPLETED) { finish() }

    // initialize playable
    playable = intent.extras!!.getSerializable(BrightcovePlayerAdapter.KEY_PLAYABLE) as Playable
    videoView.setVideoURI(Uri.parse(playable.contentVideoURL))
    videoView.eventEmitter.emit(EventType.ENTER_FULL_SCREEN)
    videoView.eventEmitter.on(EventType.EXIT_FULL_SCREEN) { finish() }

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

}
