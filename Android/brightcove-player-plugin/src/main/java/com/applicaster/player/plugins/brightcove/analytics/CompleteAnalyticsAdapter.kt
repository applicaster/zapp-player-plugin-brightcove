package com.applicaster.player.plugins.brightcove.analytics

import android.util.Log
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
        when (getAnalyticsEventType()) {
            AnalyticsEvent.PLAY_VOD_ITEM -> {
                AnalyticsAgentUtil.logTimedEvent(AnalyticsEvent.PLAY_VOD_ITEM.value, collectPlayVODItemProperties(playable))
            }
            AnalyticsEvent.PLAY_LIVE_STREAM -> {
                AnalyticsAgentUtil.logTimedEvent(AnalyticsEvent.PLAY_VOD_ITEM.value, collectPlayLiveStreamProperties(playable))
            }
            else -> {}
        }
    }

    override fun endTrack(playable: Playable, mode: AnalyticsAdapter.PlayerMode) {
        switchInstanceCounter = 0
        startTimeInVideoMillis = 0L
        when (getAnalyticsEventType()) {
            AnalyticsEvent.PLAY_VOD_ITEM -> {
                AnalyticsAgentUtil.endTimedEvent(AnalyticsEvent.PLAY_VOD_ITEM.value, collectPlayVODItemProperties(playable))
            }
            AnalyticsEvent.PLAY_LIVE_STREAM -> {
                AnalyticsAgentUtil.endTimedEvent(AnalyticsEvent.PLAY_VOD_ITEM.value, collectPlayLiveStreamProperties(playable))
            }
            else -> {}
        }
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
     * Whether or not the user completed the item (got to the end of the video before closing)
     */
    private fun getCompletion(): Pair<String, String> {
        return if (this.completed == Completed.YES)
            Pair(AnalyticsEvent.COMPLETED.value, Completed.YES.value)
        else
            Pair(AnalyticsEvent.COMPLETED.value, Completed.NO.value)
    }

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
    enum class Completed(val value: String) {
        YES("Yes"), NO("No")
    }

    enum class SeekDirection(val value: String) {
        FAST_FORWARD("Fast Forward"),
        REWIND("Rewind")
    }
}