package com.applicaster.player.plugins.brightcove.analytics

import com.applicaster.analytics.AnalyticsAgentUtil
import com.applicaster.atom.model.APAtomEntry
import com.applicaster.atom.model.APAtomEntry.APAtomEntryPlayable
import com.applicaster.player.plugins.brightcove.analytics.AnalyticsAdapter.PlayerMode
import com.applicaster.player.plugins.brightcove.analytics.AnalyticsAdapter.PlayerMode.FULLSCREEN
import com.applicaster.player.plugins.brightcove.analytics.AnalyticsAdapter.PlayerMode.INLINE
import com.applicaster.plugin_manager.playersmanager.Playable
import com.applicaster.plugin_manager.playersmanager.internal.PlayableType
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
    private var isLive: Boolean = false

    override fun startTrack(playable: Playable, mode: PlayerMode) {
        this.isLive = playable.isLive
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
                getItemId(playable),
                viewParams(mode),
                priceParams(playable)
            )
        )

    /**
     * The ID of the item
     */
    protected fun getItemId(playable: Playable): Pair<String, String> =
        AnalyticsEvent.ITEM_ID.value to playable.playableId

    /**
     * Whether the video is VOD or Live
     */
    protected fun getVideoType(): Pair<String, String> =
        if (this.isLive)
            AnalyticsEvent.VIDEO_TYPE.value to VideoType.LIVE.value
        else
            AnalyticsEvent.VIDEO_TYPE.value to VideoType.VOD.value

    /**
     * The timecode of the duration at point of making the switch.
     * Only applicable if Video Type is VOD"
     */
    protected fun getTimecode(): Pair<String, String> =
        if (!this.isLive)
            AnalyticsEvent.TIMECODE.value to parseDuration(view.currentPosition.toLong())
        else
            AnalyticsEvent.TIMECODE.value to parseDuration(0L)

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

    protected fun getItemDuration() =
        ITEM_DURATION to parseDuration(view.duration.toLong())

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

    /**
     * Data type of VOD Item
     * Only applicable if Video Type is VOD
     */
    protected fun getVODType(playable: Playable): Pair<String, String> =
        when {
            (playable is APAtomEntryPlayable) -> Pair(AnalyticsEvent.VOD_TYPE.value, VODType.ATOM.value)
            (playable.playableType == PlayableType.Youtube) -> Pair(
                AnalyticsEvent.VOD_TYPE.value,
                VODType.YOUTUBE.value
            )
            else -> Pair(AnalyticsEvent.VOD_TYPE.value, VODType.APPLICASTER_MODEL.value)
        }

    protected fun getItemName(playable: Playable) =
        AdAnalyticsAdapter.ITEM_NAME to when (playable) {
            is APAtomEntryPlayable -> playable.entry.title ?: ""
            else -> ""
        }

    /**
     * What view the player was in when the video playing session began
     */
    protected fun getViewMode(mode: PlayerMode): Pair<String, String> =
        when (mode) {
            INLINE -> AnalyticsEvent.VIEW.value to ViewMode.INLINE.value
            FULLSCREEN -> AnalyticsEvent.VIEW.value to ViewMode.FULL_SCREEN.value
        }

    protected enum class ViewMode(val value: String) {
        INLINE("Inline"),
        FULL_SCREEN("Full Screen")
    }

    protected enum class VideoType(val value: String) {
        LIVE("Live"), VOD("VOD")
    }

    protected enum class VODType(val value: String) {
        APPLICASTER_MODEL("Applicaster Model"),
        YOUTUBE("Youtube"),
        ATOM("Atom")
    }

    // Complete analytics events
    protected enum class AnalyticsEvent(val value: String) {
        PLAY_VOD_ITEM("Play VOD Item"),
        PLAY_LIVE_STREAM("Play Live Stream"),
        SWITCH_PLAYER_VIEW("Switch player view"),
        PAUSE("Pause"),
        SEEK("Seek"),
        TAP_REWIND("Tap Rewind"),
        ORIGINAL_VIEW("Original View"),
        COMPLETED("Completed"),
        NEW_VIEW("New View"),
        VIEW("View"),
        ITEM_ID("Item ID"),
        VIDEO_TYPE("Video Type"),
        TIMECODE("Timecode"),
        SWITCH_INSTANCE("Switch Instance"),
        DURATION_IN_VIDEO("Duration In Video"),
        VOD_TYPE("VOD Type"),
        SEEK_DIRECTION("Seek Direction"),
        TIMECODE_FROM("Timecode From"),
        TIMECODE_TO("Timecode To"),
        AD_BREAKS_SKIPPED("Ad Breaks Skipped")
    }

    protected val Playable.isFree: Boolean
        get() = when {
            this is APAtomEntryPlayable -> this.entry.isFree
            else -> true
        }

    companion object {
        const val ITEM_DURATION = "Item Duration"
    }

}

private val Playable.analyticsEvent: String
    get() = when {
        isLive -> "Play Live Stream"
        else -> AnalyticsAgentUtil.PLAY_VOD_ITEM
    }
