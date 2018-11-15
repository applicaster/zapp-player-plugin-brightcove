package com.applicaster.player.plugins.brightcove

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.view.ViewGroup
import com.applicaster.player.defaultplayer.BasePlayer
import com.applicaster.player.plugins.brightcove.AnalyticsAdapter.PlayerMode.INLINE
import com.applicaster.plugin_manager.playersmanager.Playable
import com.applicaster.plugin_manager.playersmanager.PlayableConfiguration
import com.brightcove.player.view.BrightcoveExoPlayerVideoView
import com.brightcove.player.view.BrightcoveVideoView

/**
 * BrightcovePlayerAdapter:
 * This adapter extends the BasePlayer class which implements the PlayerContract.
 * This class includes the various initialization methods as well as several playback methods.
 */
class BrightcovePlayerAdapter : BasePlayer() {

  private lateinit var videoView: BrightcoveVideoView
  private lateinit var analyticsAdapter: AnalyticsAdapter

  /**
   * initialization of the player instance with a playable item
   */
  override fun init(playable: Playable, context: Context) {
    this.init(listOf(playable), context)
  }

  /**
   * initialization of the player instance with  multiple playable items
   */
  override fun init(playList: List<Playable>, context: Context) {
    super.init(playList, context)
    videoView = BrightcoveExoPlayerVideoView(context)
    analyticsAdapter = MorpheusAnalyticsAdapter(videoView)
  }

  /**
   * start the player in fullscreen with configuration.
   *
   * @param playableConfiguration player configuration.
   * @param requestCode request code if needed - if not send NO_REQUEST_CODE instead.
   */
  override fun playInFullscreen(
    playableConfiguration: PlayableConfiguration?, requestCode: Int,
    context: Context
  ) {
    super.playInFullscreen(playableConfiguration, requestCode, context)
    val intent = Intent(context, BrightcovePlayerActivity::class.java)
    firstPlayable.also {
      intent.putExtra(KEY_PLAYABLE, it)
      intent.flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
      context.startActivity(intent)
    }
  }

  /**
   * Add the player into the given container.
   *
   * @param viewGroup The container the player should be added to
   */
  override fun attachInline(viewGroup: ViewGroup) {
    super.attachInline(viewGroup)
    viewGroup.addView(videoView)
    videoView.finishInitialization()
    // startTrack inline
    analyticsAdapter.startTrack(firstPlayable, INLINE)
  }

  /**
   * Remove the player from it's container.
   *
   * @param viewGroup The container that the player is attached to
   */
  override fun removeInline(viewGroup: ViewGroup) {
    super.removeInline(viewGroup)
    viewGroup.removeView(videoView)
    // startTrack inline
    analyticsAdapter.endTrack(firstPlayable, INLINE)
  }

  /**
   * start the player in inline with configuration.
   */
  override fun playInline(configuration: PlayableConfiguration?) {
    super.playInline(configuration)
    firstPlayable.also {
      videoView.setVideoURI(Uri.parse(it.contentVideoURL))
      videoView.start()
    }
  }

  /**
   * Stops playing the inline player.
   */
  override fun stopInline() {
    super.stopInline()
    videoView.stopPlayback()
  }

  /**
   * Pauses playing the inline player
   */
  override fun pauseInline() {
    super.pauseInline()
    videoView.pause()
  }

  /**
   * Resumes playing the inline player.
   */
  override fun resumeInline() {
    super.resumeInline()
    videoView.start()
  }

  companion object {

    internal const val KEY_PLAYABLE = "playable"
  }
}
