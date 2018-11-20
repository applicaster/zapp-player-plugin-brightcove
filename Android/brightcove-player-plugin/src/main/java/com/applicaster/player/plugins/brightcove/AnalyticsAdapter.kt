package com.applicaster.player.plugins.brightcove

import com.applicaster.analytics.AnalyticsAgentUtil
import com.applicaster.atom.model.APAtomEntry.APAtomEntryPlayable
import com.applicaster.player.plugins.brightcove.AnalyticsAdapter.PlayerMode
import com.applicaster.player.plugins.brightcove.AnalyticsAdapter.PlayerMode.FULLSCREEN
import com.applicaster.player.plugins.brightcove.AnalyticsAdapter.PlayerMode.INLINE
import com.applicaster.plugin_manager.playersmanager.Playable
import com.brightcove.player.event.EventType
import com.brightcove.player.view.BaseVideoView


interface AnalyticsAdapter {

  fun startTrack(playable: Playable, mode: PlayerMode)
  fun endTrack(playable: Playable, mode: PlayerMode)

  enum class PlayerMode {
    INLINE, FULLSCREEN
  }
}

class MorpheusAnalyticsAdapter(private val view: BaseVideoView) : AnalyticsAdapter {

  private var completed = false

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
    playable.analyticsParams.plus(arrayOf(viewParams(mode), priceParams(playable)))

  private fun viewParams(mode: PlayerMode) =
    AnalyticsAgentUtil.VIEW to when (mode) {
      INLINE -> AnalyticsAgentUtil.INLINE_PLAYER
      FULLSCREEN -> AnalyticsAgentUtil.FS_PLAYER
    }

  private fun priceParams(playable: Playable) =
    AnalyticsAgentUtil.IS_FREE_VIDEO to when {
      playable.isFree -> "Free"
      else -> "Paid"
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

private val Playable.isFree: Boolean
  get() = when {
    this is APAtomEntryPlayable -> this.entry.getExtension("free", false, Boolean::class.java)
    else -> true
  }
