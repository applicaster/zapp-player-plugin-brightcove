package com.applicaster.player.plugins.brightcove

import android.net.Uri
import android.os.Bundle
import android.view.View
import com.applicaster.player.plugins.brightcove.AnalyticsAdapter.PlayerMode.FULLSCREEN
import com.applicaster.plugin_manager.playersmanager.Playable
import com.brightcove.player.event.EventType
import com.brightcove.player.appcompat.BrightcovePlayerActivity as CoreActivity

class BrightcovePlayerActivity : CoreActivity() {

  private lateinit var playable: Playable
  private lateinit var analyticsAdapter: AnalyticsAdapter

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)

    playable = intent.extras!!.getSerializable(BrightcovePlayerAdapter.KEY_PLAYABLE) as Playable

    // inject layout
    setContentView(R.layout.activity_brightcove_player)
    // init video view
    with(baseVideoView) {
      eventEmitter.emit(EventType.ENTER_FULL_SCREEN)
      eventEmitter.on(EventType.COMPLETED) { finish() }
      setVideoURI(Uri.parse(playable.contentVideoURL))
    }
    // init close btn
    with(findViewById<View>(R.id.fullscreen_close)) {
      baseVideoView.eventEmitter.on("didShowMediaControls") { visibility = View.VISIBLE }
      baseVideoView.eventEmitter.on("didHideMediaControls") { visibility = View.GONE }
      setOnClickListener { finish() }
    }

    // initialize tools
    analyticsAdapter = MorpheusAnalyticsAdapter(baseVideoView)
    analyticsAdapter.startTrack(playable, FULLSCREEN)
  }

  override fun onStart() {
    super.onStart()
    baseVideoView.start()
  }

  override fun onDestroy() {
    super.onDestroy()
    analyticsAdapter.endTrack(playable, FULLSCREEN)
  }

}
