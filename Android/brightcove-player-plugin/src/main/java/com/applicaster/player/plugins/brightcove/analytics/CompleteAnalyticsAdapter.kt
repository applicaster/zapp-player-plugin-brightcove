package com.applicaster.player.plugins.brightcove.analytics

import com.applicaster.analytics.AnalyticsAgentUtil
import com.applicaster.atom.model.APAtomEntry
import com.applicaster.plugin_manager.playersmanager.Playable
import com.applicaster.plugin_manager.playersmanager.internal.PlayableType
import com.brightcove.player.event.Event
import com.brightcove.player.event.EventType
import com.brightcove.player.view.BrightcoveVideoView

class CompleteAnalyticsAdapter(
    private val view: BrightcoveVideoView
) : MorpheusAnalyticsAdapter(view) {

    private var playerMode: AnalyticsAdapter.PlayerMode = AnalyticsAdapter.PlayerMode.INLINE
    private var switchInstanceCounter: Int = 0
    private var startTimeInVideoMillis: Long = 0L

    private var playableProps: Map<String, String> = mapOf(Pair("", ""))
    private var isLive: Boolean = false
    private var completed: Completed = Completed.NO

    private var originalView: Pair<String, String> = Pair(AnalyticsEvent.ORIGINAL_VIEW.value, "")
    private var newView: Pair<String, String> = Pair(AnalyticsEvent.NEW_VIEW.value, "")
    private var viewMode: Pair<String, String> = Pair(AnalyticsEvent.VIEW.value, "")

    override fun startTrack(playable: Playable, mode: AnalyticsAdapter.PlayerMode) {
        this.isLive = playable.isLive
        initEventEmitters()
        setViewMode(mode)
        startTimeInVideoMillis = System.currentTimeMillis()
        playableProps = collectPlayableProperties(playable)
        AnalyticsAgentUtil.logTimedEvent(AnalyticsEvent.PLAY_VOD_ITEM.value, collectPlayVODItemProperties(playable))
        AnalyticsAgentUtil.logTimedEvent(
            AnalyticsEvent.PLAY_LIVE_STREAM.value,
            collectPlayLiveStreamProperties(playable)
        )
    }

    override fun endTrack(playable: Playable, mode: AnalyticsAdapter.PlayerMode) {
        switchInstanceCounter = 0
        startTimeInVideoMillis = 0L
    }

    /**
     * Initialize all event listeners
     */
    private fun initEventEmitters() {
        view.eventEmitter.on(EventType.ENTER_FULL_SCREEN) {
            startTimeInVideoMillis = System.currentTimeMillis()
            switchInstanceCounter++
            originalView = getOriginalView(playerMode)
            playerMode = AnalyticsAdapter.PlayerMode.FULLSCREEN
            newView = getNewView(playerMode)
            AnalyticsAgentUtil.logEvent(
                AnalyticsEvent.SWITCH_PLAYER_VIEW.value,
                collectSwitchPlayerViewProperties(playableProps)
            )
        }

        view.eventEmitter.on(EventType.EXIT_FULL_SCREEN) {
            switchInstanceCounter++
            originalView = getOriginalView(playerMode)
            playerMode = AnalyticsAdapter.PlayerMode.INLINE
            newView = getNewView(playerMode)
            AnalyticsAgentUtil.logEvent(
                AnalyticsEvent.SWITCH_PLAYER_VIEW.value,
                collectSwitchPlayerViewProperties(playableProps)
            )
        }

        view.eventEmitter.on(EventType.PAUSE) {
            AnalyticsAgentUtil.logEvent(AnalyticsEvent.PAUSE.value, collectPauseProperties(playableProps))
        }

        view.eventEmitter.on(EventType.SEEK_TO) {
            AnalyticsAgentUtil.logEvent(AnalyticsEvent.SEEK.value, collectSeekProperties(playableProps, it))
        }

        view.eventEmitter.on(EventType.REWIND) {
            AnalyticsAgentUtil.logEvent(AnalyticsEvent.TAP_REWIND.value, collectRewindProperties(playableProps))
        }

        view.eventEmitter.on(EventType.COMPLETED) {
            this.completed = Completed.YES
        }
    }

    /**
     * Collect all playable properties
     */
    private fun collectPlayableProperties(playable: Playable) =
        mapOf(
            priceParams(playable),
            getItemId(playable),
            getItemName(playable),
            getVideoType(),
            getVODType(playable)
        )

    /**
     * Measures that a video item is played, and for how long.
     */
    private fun collectPlayVODItemProperties(playable: Playable) =
        mapOf(
            priceParams(playable),
            getItemId(playable),
            getItemName(playable),
            getItemDuration(),
            getCompletion(),
            getVODType(playable),
            viewMode
        )

    /**
     * Identify how many live stream plays are triggered and for what channels
     */
    private fun collectPlayLiveStreamProperties(playable: Playable) =
        mapOf(
            priceParams(playable),
            getItemId(playable),
            getItemName(playable),
            viewMode
        )


    /**
     * Collect "Switch Player View" properties and add playable properties to result
     */
    private fun collectSwitchPlayerViewProperties(playableProps: Map<String, String>) =
        mapOf(
            originalView,
            newView,
            getTimecode(),
            getItemDuration(),
            getSwitchInstanceCount(),
            getDurationInVideo()
        ) + playableProps

    /**
     * Collect "Pause" properties and add playable properties to result
     */
    private fun collectPauseProperties(playableProps: Map<String, String>) =
        mapOf(
            viewMode,
            getTimecode(),
            getItemDuration(),
            getDurationInVideo()
        ) + playableProps

    /**
     * Collect "Seek" properties and add playable properties to result
     */
    private fun collectSeekProperties(playableProps: Map<String, String>, event: Event) =
        mapOf(
            newView,
            getTimecodeFrom(event),
            getTimecodeTo(event),
            getSeekDirection(event),
            getItemDuration()
        ) + playableProps

    /**
     * Collect "Rewind" properties and add playable properties to result
     */
    private fun collectRewindProperties(playableProps: Map<String, String>) =
        mapOf(
            viewMode,
            getTimecode(),
            getItemDuration()
        ) + playableProps

    /**
     * Set initial view mode
     */
    private fun setViewMode(mode: AnalyticsAdapter.PlayerMode) {
        when (mode) {
            AnalyticsAdapter.PlayerMode.FULLSCREEN -> this.playerMode = AnalyticsAdapter.PlayerMode.FULLSCREEN
            AnalyticsAdapter.PlayerMode.INLINE -> this.playerMode = AnalyticsAdapter.PlayerMode.INLINE
        }
        viewMode = getViewMode(playerMode)
    }

    /**
     * The view the user switched from
     */
    private fun getOriginalView(mode: AnalyticsAdapter.PlayerMode): Pair<String, String> =
        when (mode) {
            AnalyticsAdapter.PlayerMode.INLINE -> AnalyticsEvent.ORIGINAL_VIEW.value to ViewMode.INLINE.value
            AnalyticsAdapter.PlayerMode.FULLSCREEN -> AnalyticsEvent.ORIGINAL_VIEW.value to ViewMode.FULL_SCREEN.value
        }

    /**
     * The view the user switched to
     */
    private fun getNewView(mode: AnalyticsAdapter.PlayerMode): Pair<String, String> =
        when (mode) {
            AnalyticsAdapter.PlayerMode.INLINE -> AnalyticsEvent.NEW_VIEW.value to ViewMode.INLINE.value
            AnalyticsAdapter.PlayerMode.FULLSCREEN -> AnalyticsEvent.NEW_VIEW.value to ViewMode.FULL_SCREEN.value
        }

    /**
     * What view the player was in when the video playing session began
     */
    private fun getViewMode(mode: AnalyticsAdapter.PlayerMode): Pair<String, String> =
        when (mode) {
            AnalyticsAdapter.PlayerMode.INLINE -> AnalyticsEvent.VIEW.value to ViewMode.INLINE.value
            AnalyticsAdapter.PlayerMode.FULLSCREEN -> AnalyticsEvent.VIEW.value to ViewMode.FULL_SCREEN.value
        }

    /**
     * Whether or not the user completed the item (got to the end of the video before closing)
     */
    private fun getCompletion(): Pair<String, String> =
        when (this.completed) {
            Completed.YES -> Pair(AnalyticsEvent.COMPLETED.value, Completed.YES.value)
            Completed.NO -> Pair(AnalyticsEvent.COMPLETED.value, Completed.NO.value)
        }


    /**
     * The ID of the item
     */
    private fun getItemId(playable: Playable): Pair<String, String> =
        AnalyticsEvent.ITEM_ID.value to playable.playableId

    /**
     * Whether the video is VOD or Live
     */
    private fun getVideoType(): Pair<String, String> =
        if (this.isLive)
            AnalyticsEvent.VIDEO_TYPE.value to VideoType.LIVE.value
        else
            AnalyticsEvent.VIDEO_TYPE.value to VideoType.VOD.value

    /**
     * The timecode of the duration at point of making the switch.
     * Only applicable if Video Type is VOD"
     */
    private fun getTimecode(): Pair<String, String> =
        if (!this.isLive)
            AnalyticsEvent.TIMECODE.value to parseDuration(view.currentPosition.toLong())
        else
            AnalyticsEvent.TIMECODE.value to parseDuration(0L)

    /**
     * The number of times the user has already switched view in the video play session.
     * For example, if the user already switched views once before, this value would be 2.
     */
    private fun getSwitchInstanceCount(): Pair<String, String> =
        AnalyticsEvent.SWITCH_INSTANCE.value to switchInstanceCounter.toString()

    /**
     * This actually differs from timecode in that users can pause, rewind, seek forward, etc.
     */
    private fun getDurationInVideo(): Pair<String, String> {
        val result = System.currentTimeMillis() - startTimeInVideoMillis
        return AnalyticsEvent.DURATION_IN_VIDEO.value to parseDuration(result)
    }

    /**
     * Data type of VOD Item
     * Only applicable if Video Type is VOD
     */
    private fun getVODType(playable: Playable): Pair<String, String> =
        when {
            (playable is APAtomEntry.APAtomEntryPlayable) -> Pair(AnalyticsEvent.VOD_TYPE.value, VODType.ATOM.value)
            (playable.playableType == PlayableType.Youtube) -> Pair(
                AnalyticsEvent.VOD_TYPE.value,
                VODType.YOUTUBE.value
            )
            else -> Pair(AnalyticsEvent.VOD_TYPE.value, VODType.APPLICASTER_MODEL.value)
        }

    /**
     * Whether the user seeks forward or backwards
     */
    private fun getSeekDirection(event: Event): Pair<String, String> {
        var seekPosition: Int = 0
        var fromSeekPosition: Int = 0
        val propertiesMap: Map<String, Any> = event.properties
        if (propertiesMap.containsKey("seekPosition") && propertiesMap["seekPosition"] is Int)
            seekPosition = propertiesMap["seekPosition"] as Int
        if (propertiesMap.containsKey("fromSeekPosition") && propertiesMap["fromSeekPosition"] is Int)
            fromSeekPosition = propertiesMap["fromSeekPosition"] as Int
        val result: Int = seekPosition - fromSeekPosition
        return if (result < 0)
            Pair(AnalyticsEvent.SEEK_DIRECTION.value, SeekDirection.REWIND.value)
        else
            Pair(AnalyticsEvent.SEEK_DIRECTION.value, SeekDirection.FAST_FORWARD.value)
    }

    /**
     * The timecode of the duration at point of starting the seek
     */
    private fun getTimecodeFrom(event: Event): Pair<String, String> {
        var fromSeekPosition: Int = 0
        val propertiesMap: Map<String, Any> = event.properties
        if (propertiesMap.containsKey("fromSeekPosition") && propertiesMap["fromSeekPosition"] is Int)
            fromSeekPosition = propertiesMap["fromSeekPosition"] as Int
        return Pair(AnalyticsEvent.TIMECODE_FROM.value, parseDuration(fromSeekPosition.toLong()))
    }

    /**
     * The timecode of the duration at the point the seek action stops
     */
    private fun getTimecodeTo(event: Event): Pair<String, String> {
        var seekPositionTo: Int = 0
        val propertiesMap: Map<String, Any> = event.properties
        if (propertiesMap.containsKey("seekPosition") && propertiesMap["seekPosition"] is Int)
            seekPositionTo = propertiesMap["seekPosition"] as Int
        return Pair(AnalyticsEvent.TIMECODE_TO.value, parseDuration(seekPositionTo.toLong()))
    }

    // Events properties
    private enum class ViewMode(val value: String) {
        INLINE("Inline"),
        FULL_SCREEN("Full Screen")
    }

    private enum class Completed(val value: String) {
        YES("Yes"), NO("No")
    }

    private enum class VideoType(val value: String) {
        LIVE("Live"), VOD("VOD")
    }

    private enum class VODType(val value: String) {
        APPLICASTER_MODEL("Applicaster Model"),
        YOUTUBE("Youtube"),
        ATOM("Atom")
    }

    private enum class SeekDirection(val value: String) {
        FAST_FORWARD("Fast Forward"),
        REWIND("Rewind")
    }

    // Complete analytics events
    enum class AnalyticsEvent(val value: String) {
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
}