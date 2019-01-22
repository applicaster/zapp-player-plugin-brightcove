package com.applicaster.player.plugins.brightcove

import android.util.Log
import com.applicaster.analytics.AnalyticsAgentUtil
import com.applicaster.atom.model.APAtomEntry
import com.applicaster.plugin_manager.playersmanager.Playable
import com.brightcove.ima.GoogleIMAEventType
import com.brightcove.player.event.Event
import com.brightcove.player.event.EventType
import com.brightcove.player.view.BrightcoveVideoView
import com.google.ads.interactivemedia.v3.api.AdError

class ErrorHandlingAnalyticsAdapter(private val videoView: BrightcoveVideoView) : MorpheusAnalyticsAdapter(videoView) {

    private val TAG = ErrorHandlingAnalyticsAdapter::class.java.simpleName

    private var adProviderErrorCode: String = ""
    private val analyticsParams: HashMap<String, String> = HashMap()


    override fun startTrack(playable: Playable, mode: AnalyticsAdapter.PlayerMode) {
        Log.v(TAG, "startTrack")
        videoView.eventEmitter.on(
            EventType.AD_ERROR
        ) { event ->
            Log.v(TAG, event.type)
            // Push all collected data to map
            analyticsParams.run {
                // Put all collected maps to result map
                putAll(collectPlayableProperties(playable, mode))
                putAll(completionParams(playable, isCompleted()))

                // Put pairs(first: key, second: value) to result map
                getErrorCode(event).run { put(first, second) }
                getErrorMessage(event).run { put(first, second) }
                getAdProviderErrorCode().run { put(first, second) }
            }

            logTimedEvent(playable)
        }

        videoView.eventEmitter.on(
            GoogleIMAEventType.DID_FAIL_TO_PLAY_AD
        ) { adProviderErrorCode = it.type }
    }

    override fun endTrack(playable: Playable, mode: AnalyticsAdapter.PlayerMode) {
        Log.v(TAG, "endTrack")
    }

    /**
     *  Send collected data to analytics agent
     */
    private fun logTimedEvent(playable: Playable) {
        AnalyticsAgentUtil.logTimedEvent(
            playable.videoAdErrorEvent,
            analyticsParams
        )
    }

    private fun collectPlayableProperties(playable: Playable, mode: AnalyticsAdapter.PlayerMode) =
        arrayOf(
            viewParams(mode),
            priceParams(playable),
            getDataParams(playable),
            getItemDuration(),
            getItemName(playable),
            getItemLink(playable),
            getVodType(playable),
            getVideoPlayerPlugin(),
            getAdvertisingProvider()
        )

    private fun getDataParams(playable: Playable) =
        ENTRY_ID to when (playable) {
            is APAtomEntry.APAtomEntryPlayable -> playable.entry.id ?: ""
            else -> ""
        }

    private fun getItemDuration() =
        ITEM_DURATION to parseDuration(videoView.duration.toLong())


    private fun getItemName(playable: Playable) =
        ITEM_NAME to when (playable) {
            is APAtomEntry.APAtomEntryPlayable -> playable.entry.title ?: ""
            else -> ""
        }

    private fun getItemLink(playable: Playable) =
        ITEM_LINK to (playable.contentVideoURL ?: "")

    private fun getVideoPlayerPlugin() =
        VIDEO_PLAYER_PLUGIN to "Brightcove Player"

    private fun getErrorCode(event: Event): Pair<String, String> {
        val adError = event.properties["error"] as? AdError
        val errorCodeName = adError?.errorCode?.name ?: ""
        return ERROR_CODE to errorCodeName
    }

    private fun getErrorMessage(event: Event): Pair<String, String> {
        val adError = event.properties["error"] as? AdError
        val errorDetailMessage = adError?.message ?: ""
        return ERROR_MESSAGE to errorDetailMessage
    }

    private fun getAdvertisingProvider() =
        ADVERTISING_PROVIDER to "IMA"

    private fun getAdProviderErrorCode() =
        AD_PROVIDER_ERROR_CODE to adProviderErrorCode

    /**
     *  Event name
     */
    private val Playable.videoAdErrorEvent: String
        get() = "Video Ad Error"


    companion object {
        const val ENTRY_ID = "Entry ID"
        const val ITEM_DURATION = "Item Duration"
        const val ITEM_NAME = "Item Name"
        const val ITEM_LINK = "Item Link"
        const val VIDEO_PLAYER_PLUGIN = "Video Player Plugin"
        const val ERROR_CODE = "Error Code"
        const val ERROR_MESSAGE = "Error Message"
        const val ADVERTISING_PROVIDER = "Advertising Provider"
        const val AD_PROVIDER_ERROR_CODE = "Ad Provider Error Code"
    }

}