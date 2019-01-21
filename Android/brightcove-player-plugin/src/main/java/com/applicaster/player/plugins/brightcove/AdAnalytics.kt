package com.applicaster.player.plugins.brightcove

import android.util.Log
import com.applicaster.analytics.AnalyticsAgentUtil
import com.applicaster.atom.model.APAtomEntry
import com.applicaster.plugin_manager.playersmanager.Playable
import com.brightcove.ima.GoogleIMAEventType
import com.brightcove.player.event.Event
import com.brightcove.player.event.EventEmitter
import com.brightcove.player.event.EventType
import com.brightcove.player.view.BrightcoveVideoView
import com.google.ads.interactivemedia.v3.api.AdError
import com.google.ads.interactivemedia.v3.api.AdEvent
import com.google.ads.interactivemedia.v3.api.AdsManager


class AdAnalytics(private val videoView: BrightcoveVideoView) : MorpheusAnalyticsAdapter(videoView), AdEvent.AdEventListener {

    private val TAG = AdAnalytics::class.java.simpleName

    private lateinit var eventEmitter: EventEmitter
    private lateinit var adsManager: AdsManager

    private var collectedParams: MutableMap<String, String> = HashMap()

    // Watch video advertisement properties
    private var videoAdType = Pair(VIDEO_AD_TYPE, AdVideoType.Preroll.name)
    private var adUnit = Pair(AD_UNIT, "")
    private var adProvider = Pair(AD_PROVIDER, "IMA")
    private var skippable = Pair(SKIPPABLE, "")
    private var skipped = Pair(SKIPPED, "N/A")
    private var contentVideoDuration = Pair(CONTENT_VIDEO_DURATION, parseDuration(0, isInMilliseconds = false))
    private var atomFeedName = Pair(ATOM_FEED_NAME, "")
    private var itemName = Pair(ITEM_NAME, "")
    private var vodType = Pair(VOD_TYPE, "")
    private var isFree = Pair(FREE_OR_PAID, "")
    private var adBreakTime = Pair(AD_BREAK_TIME, "")
    private var adBreakDuration = Pair(AD_BREAK_DURATION, "")
    private var adExitMethod = Pair(AD_EXIT_METHOD, "Unspecified")
    private var timeWhenExited = Pair(TIME_WHEN_EXITED, parseDuration(0, isInMilliseconds = false))
    private var adServerErrorCode = Pair(AD_SERVER_ERROR, "N/A")

    /**
     *  Start tracking
     */
    override fun startTrack(playable: Playable, mode: AnalyticsAdapter.PlayerMode) {
        Log.v(TAG, "startTrack")
        setupComponents()
        setupAdsManager()
        collectParams(playable)
    }

    /**
     *  End tracking
     */
    override fun endTrack(playable: Playable, mode: AnalyticsAdapter.PlayerMode) {
        Log.v(TAG, "endTrack")
        collectParams(playable)
        adsManager.removeAdEventListener(this)
    }

    private fun setupComponents() {
        eventEmitter = videoView.eventEmitter
    }

    /**
     * Collect all Watch Video Advertisement properties
     */
    private fun collectParams(playable: Playable) {
        collectAdInfo(playable)
    }

    /**
     *  Set all collected analytics params analytics params map
     */
    private fun setAllCollectedParams() {
        collectedParams.clear()
        collectedParams.putAll(
            arrayOf(
                adUnit,
                adProvider,
                skippable,
                contentVideoDuration,
                atomFeedName,
                itemName,
                vodType,
                isFree,
                timeWhenExited,
                adBreakTime,
                videoAdType,
                adBreakDuration,
                adExitMethod,
                skipped
            )
        )
    }

    private fun collectAdInfo(playable: Playable) {

        // Collect data for ad started  event
        eventEmitter.on(
            EventType.AD_STARTED
        ) { event -> Log.v(TAG, event.type)
            adUnit = getAdUnit(event)
            adProvider = getAdProvider()
            skippable = isSkippable(event)
            contentVideoDuration = getContentVideoDuration()
            atomFeedName = getAtomFeedName(playable)
            itemName = getItemName(playable)
            vodType = getVodType()
            isFree = priceParams(playable)

            setAllCollectedParams()

            logTimedEvent(playable)
        }

        // Collect data for ad completed event
        eventEmitter.on(
            EventType.AD_COMPLETED
        ) { event -> Log.v(TAG, event.type)
            adUnit = getAdUnit(event)
            adProvider = getAdProvider()
            skippable = isSkippable(event)
            contentVideoDuration = getContentVideoDuration()
            atomFeedName = getAtomFeedName(playable)
            itemName = getItemName(playable)
            vodType = getVodType()
            isFree = priceParams(playable)

            setAllCollectedParams()

            logTimedEvent(playable)
        }

        // Collect data for ad progress event
        eventEmitter.on(
            EventType.AD_PROGRESS
        ) { event ->
            timeWhenExited = getTimeWhenExited(event)
        }

        videoView.eventEmitter.on(
            GoogleIMAEventType.DID_FAIL_TO_PLAY_AD
        ) {
            val adError = it.properties["error"] as? AdError
            adServerErrorCode = AD_SERVER_ERROR to (adError?.errorCode?.name ?: "N/A")
            setAllCollectedParams()
        }
    }

    /**
     *  Send collected data to analytics agent
     */
    private fun logTimedEvent(playable: Playable) {
        AnalyticsAgentUtil.logTimedEvent(
            playable.watchVideoAdEvent,
            collectedParams
        )
    }

    override fun onAdEvent(event: AdEvent) {
        when (event.type) {
            AdEvent.AdEventType.STARTED -> {
                adBreakTime = getAdBreakTime()
                videoAdType = getVideoAdType()
                adBreakDuration = getAdBreakDuration(event)
            }

            AdEvent.AdEventType.SKIPPED -> {
                adExitMethod = getAdExitMethod(AdExitMethod.SKIPPED)
                skipped = isSkipped(true)
                setAllCollectedParams()
            }

            AdEvent.AdEventType.COMPLETED -> {
                adExitMethod = getAdExitMethod(AdExitMethod.COMPLETED)
                skipped = isSkipped(false)
            }

            AdEvent.AdEventType.CLICKED -> {
                adExitMethod = getAdExitMethod(AdExitMethod.CLICKED)
                setAllCollectedParams()
            }

            // default
            else -> {}
        }
    }

    private fun setupAdsManager() {
        eventEmitter.on(
            GoogleIMAEventType.ADS_MANAGER_LOADED
        ) { event ->
            adsManager = event.properties["adsManager"] as AdsManager
            adsManager.addAdEventListener(this)
        }
    }

    private fun getVideoAdType(): Pair<String, String> {
        var adVideoType = AdVideoType.Preroll
        when {
            (videoView.currentPosition > 0
                    && videoView.currentPosition < videoView.duration) -> adVideoType = AdVideoType.Midroll
            videoView.currentPosition == videoView.duration -> adVideoType = AdVideoType.Postroll
        }
        return VIDEO_AD_TYPE to adVideoType.name
    }

    private fun getAdProvider(): Pair<String, String> = AD_PROVIDER to "IMA"

    private fun getAdUnit(event: Event): Pair<String, String> {
        return AD_UNIT to when (event.properties["adTagUrl"]) {
            is String -> event.properties["adTagUrl"] as String
            else -> ""
        }
    }

    private fun isSkippable(event: Event): Pair<String, String> {
        val adEvent = event.properties["adEvent"] as AdEvent
        return SKIPPABLE to when(adEvent.ad.isSkippable) {
            false -> "No"
            true -> "Yes"
        }
    }

    private fun isSkipped(value: Boolean): Pair<String, String> =
        SKIPPED to when (value) {
            false -> "No"
            true -> "Yes"
        }

    private fun getContentVideoDuration(): Pair<String, String> {
        val videoDuration = videoView.duration
        return CONTENT_VIDEO_DURATION to parseDuration(videoDuration.toLong())
    }

    private fun getAtomFeedName(playable: Playable) =
        ATOM_FEED_NAME to when (playable) {
            is APAtomEntry.APAtomEntryPlayable -> playable.entry.atomFeedName ?: ""
            else -> ""
        }

    private fun getItemName(playable: Playable) =
        ITEM_NAME to when (playable) {
            is APAtomEntry.APAtomEntryPlayable -> playable.entry.title ?: ""
            else -> ""
        }

    private fun getAdBreakTime() =
        AD_BREAK_TIME to parseDuration(videoView.currentPosition.toLong())

    private fun getAdBreakDuration(event: AdEvent) =
        AD_BREAK_DURATION to parseDuration(event.ad.duration.toLong(), isInMilliseconds = false)

    private fun getTimeWhenExited(event: Event) =
        TIME_WHEN_EXITED to parseDuration((event.properties["playheadPosition"] as Int).toLong())

    private fun getAdExitMethod(exitMethod: AdExitMethod): Pair<String, String> {
        return AD_EXIT_METHOD to when (exitMethod) {
            AdExitMethod.COMPLETED -> exitMethod.value
            AdExitMethod.SKIPPED -> exitMethod.value
            AdExitMethod.AD_SERVER_ERROR -> exitMethod.value
            AdExitMethod.CLOSED_APP -> exitMethod.value
            AdExitMethod.CLICKED -> exitMethod.value
            AdExitMethod.UNSPECIFIED -> exitMethod.value
            AdExitMethod.ANDROID_BACK_BUTTON -> exitMethod.value
        }
    }

    private fun getVodType() = VOD_TYPE to "ATOM"

    /**
     *  This one indicates that Android back button was pressed
     */
    fun backPressed() {
        adExitMethod = getAdExitMethod(AdExitMethod.ANDROID_BACK_BUTTON)
        setAllCollectedParams()
    }


    /**
     *  Watch Video Advertisement extension for Playable
     */
    private val Playable.watchVideoAdEvent
        get() = "Watch Video Advertisement"

    enum class AdExitMethod(val value: String) {
        COMPLETED("Completed"),
        SKIPPED("Skipped"),
        AD_SERVER_ERROR("Ad Server Error"),
        CLOSED_APP("Closed App"),
        CLICKED("Clicked"),
        UNSPECIFIED("Unspecified"),
        ANDROID_BACK_BUTTON("android_back_button")
    }

    enum class AdVideoType {
        Preroll,
        Midroll,
        Postroll
    }

    companion object {
        const val VIDEO_AD_TYPE = "Video Ad Type"
        const val AD_PROVIDER = "Ad Provider"
        const val AD_UNIT = "Ad Unit"
        const val SKIPPABLE = "Skippable"
        const val SKIPPED = "Skipped"
        const val CONTENT_VIDEO_DURATION = "Content Video Duration"
        const val AD_BREAK_TIME = "Ad Break Time"
        const val AD_BREAK_DURATION = "Ad Break Duration"
        const val AD_EXIT_METHOD = "Ad Exit Method"
        const val TIME_WHEN_EXITED = "Time When Exited"
        const val AD_SERVER_ERROR = "Ad Server Error"
        const val AD_CLICKED = "Ad Clicked"
        const val ITEM_NAME = "Item Name"
        const val VOD_TYPE = "VOD Type"
        const val ATOM_FEED_NAME = "ATOM Feed Name"
        const val FREE_OR_PAID = "Free/Paid"
    }

}