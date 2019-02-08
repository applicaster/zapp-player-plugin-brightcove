package com.applicaster.player.plugins.brightcove

import com.applicaster.analytics.AnalyticsAgentUtil
import com.applicaster.atom.model.APAtomEntry.APAtomEntryPlayable
import com.applicaster.player.plugins.brightcove.AnalyticsAdapter.PlayerMode
import com.applicaster.player.plugins.brightcove.AnalyticsAdapter.PlayerMode.FULLSCREEN
import com.applicaster.player.plugins.brightcove.AnalyticsAdapter.PlayerMode.INLINE
import com.applicaster.plugin_manager.playersmanager.Playable
import com.brightcove.player.event.EventType
import com.brightcove.player.view.BrightcoveVideoView
import java.util.concurrent.TimeUnit


interface AnalyticsAdapter {

    fun startTrack(playable: Playable, mode: PlayerMode)
    fun endTrack(playable: Playable, mode: PlayerMode)

    enum class PlayerMode {
        INLINE, FULLSCREEN
    }
}

open class MorpheusAnalyticsAdapter(private val view: BrightcoveVideoView) : AnalyticsAdapter {

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
        playable.analyticsParams.plus(
            arrayOf(
                dataParams(playable),
                viewParams(mode),
                priceParams(playable)
            )
        )

    private fun dataParams(playable: Playable) =
        "Item ID" to playable.playableId

    protected fun viewParams(mode: PlayerMode) =
        AnalyticsAgentUtil.VIEW to when (mode) {
            INLINE -> AnalyticsAgentUtil.INLINE_PLAYER
            FULLSCREEN -> AnalyticsAgentUtil.FS_PLAYER
        }

    protected fun priceParams(playable: Playable) =
        AnalyticsAgentUtil.IS_FREE_VIDEO to when {
            playable.isFree -> "Free"
            else -> "Paid"
        }

    protected fun completionParams(playable: Playable, completed: Boolean) =
        if (playable.isLive) emptyMap()
        else mapOf(
            AnalyticsAgentUtil.COMPLETED to when (completed) {
                true -> "Yes"
                false -> "No"
            }
        )

    protected fun isCompleted(): Boolean = completed

    /**
     * Returns a formatted duration string.
     *
     * @param duration The given duration, for example "12345".
     * @param isInMilliseconds true by default.
     * @return the formatted duration string, for example "01:05:20". If something went wrong returns an empty string.
     */
    protected fun parseDuration(duration: Long, isInMilliseconds: Boolean = true): String {
        if (duration >= 0) {
            val durationMillis = if (isInMilliseconds) duration else duration * 1000

            val hours = TimeUnit.MILLISECONDS.toHours(durationMillis)
            val minutes = TimeUnit.MILLISECONDS.toMinutes(durationMillis) % TimeUnit.HOURS.toMinutes(1)
            val seconds = TimeUnit.MILLISECONDS.toSeconds(durationMillis) % TimeUnit.MINUTES.toSeconds(1)

            return String.format("%02d:%02d:%02d", hours, minutes, seconds)
        } else if (duration == 0L) {
            return String.format("%02d:%02d:%02d", 0, 0, 0)
        }
        return ""
    }

    protected fun getVodType(playable: Playable) =
        "VOD Type" to when (playable) {
            is APAtomEntryPlayable -> "ATOM"
            else -> ""
        }

}

private val Playable.analyticsEvent: String
    get() = when {
        isLive -> "Play Live Stream"
        else -> AnalyticsAgentUtil.PLAY_VOD_ITEM
    }

private val Playable.isFree: Boolean
    get() = when {
        this is APAtomEntryPlayable -> this.entry.isFree
        else -> true
    }
