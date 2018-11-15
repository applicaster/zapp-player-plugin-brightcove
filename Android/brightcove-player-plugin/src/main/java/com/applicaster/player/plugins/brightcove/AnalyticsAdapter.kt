package com.applicaster.player.plugins.brightcove

import com.applicaster.analytics.AnalyticsAgentUtil
import com.applicaster.player.plugins.brightcove.AnalyticsAdapter.PlayerMode
import com.applicaster.player.plugins.brightcove.AnalyticsAdapter.PlayerMode.FULLSCREEN
import com.applicaster.player.plugins.brightcove.AnalyticsAdapter.PlayerMode.INLINE
import com.applicaster.plugin_manager.playersmanager.Playable
import com.brightcove.player.event.EventType
import com.brightcove.player.view.BrightcoveVideoView


interface AnalyticsAdapter {

  fun startTrack(playable: Playable, mode: PlayerMode)
  fun endTrack(playable: Playable, mode: PlayerMode)

  enum class PlayerMode {
    INLINE, FULLSCREEN
  }
}

class MorpheusAnalyticsAdapter(val view: BrightcoveVideoView) : AnalyticsAdapter {

  var completed = false

  override fun startTrack(playable: Playable, mode: PlayerMode) {
    view.eventEmitter.on(EventType.COMPLETED) { completed }
    AnalyticsAgentUtil.logTimedEvent(
      playable.analyticsEvent,
      basicParams(playable, mode)
    )
  }

  override fun endTrack(playable: Playable, mode: PlayerMode) {
    AnalyticsAgentUtil.endTimedEvent(
      playable.analyticsEvent,
      basicParams(playable, mode).plus(completionParams(playable, completed))
    )
  }

  private fun basicParams(playable: Playable, mode: PlayerMode) =
    playable.analyticsParams.plus(viewParams(mode))

  private fun viewParams(mode: PlayerMode) =
    AnalyticsAgentUtil.VIEW to when (mode) {
      INLINE -> AnalyticsAgentUtil.INLINE_PLAYER
      FULLSCREEN -> AnalyticsAgentUtil.FS_PLAYER
    }

  private fun completionParams(playable: Playable, completed: Boolean) =
    if (playable.isLive) emptyMap()
    else mapOf(
      AnalyticsAgentUtil.COMPLETED to when (completed) {
        true -> "Yes"
        false -> "No"
      }
    )

}

private val Playable.analyticsEvent: String
  get() = when {
    isLive -> AnalyticsAgentUtil.PLAY_CHANNEL
    else -> AnalyticsAgentUtil.PLAY_VOD_ITEM
  }
