package com.applicaster.player.plugins.brightcove

import android.net.Uri
import android.os.Bundle
import android.support.v7.app.AppCompatActivity
import android.view.View
import com.applicaster.player.plugins.brightcove.AnalyticsAdapter.PlayerMode.FULLSCREEN
import com.applicaster.player.plugins.brightcove.R.integer
import com.applicaster.plugin_manager.playersmanager.Playable
import com.brightcove.player.event.EventType
import com.brightcove.player.view.BrightcoveVideoView

class BrightcovePlayerActivity : AppCompatActivity() {

  private lateinit var playable: Playable
  private lateinit var videoView: BrightcoveVideoView
  private lateinit var analyticsAdapter: AnalyticsAdapter

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)

    playable = intent.extras!!.getSerializable(BrightcovePlayerAdapter.KEY_PLAYABLE) as Playable

    // inject layout
    setContentView(R.layout.activity_brightcove_player)
    // init video view
    videoView = with(findViewById<BrightcoveVideoView>(R.id.fullscreen_video_view)) {
      post { reconfigureControls() }
      eventEmitter.emit(EventType.ENTER_FULL_SCREEN)
      eventEmitter.on(EventType.COMPLETED) { finish() }
      setVideoURI(Uri.parse(playable.contentVideoURL))
      this
    }
    // init close btn
    with(findViewById<View>(R.id.fullscreen_close)) {
      videoView.eventEmitter.on("didShowMediaControls") { visibility = View.VISIBLE }
      videoView.eventEmitter.on("didHideMediaControls") { visibility = View.GONE }
      setOnClickListener { finish() }
    }

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

  private fun BrightcoveVideoView.reconfigureControls() {
    eventEmitter.emit(
      "seekControllerConfiguration",
      mapOf("seekDefault" to resources.getInteger(integer.brightcove_rewind_interval))
    )
  }

}
