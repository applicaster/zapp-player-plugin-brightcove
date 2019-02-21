package com.applicaster.player.plugins.brightcove.analytics

import android.util.Log
import com.applicaster.analytics.AnalyticsAgentUtil
import com.applicaster.plugin_manager.playersmanager.Playable
import com.brightcove.player.event.Event
import com.brightcove.player.event.EventType
import com.brightcove.player.model.Source
import com.brightcove.player.model.Video
import com.brightcove.player.view.BrightcoveVideoView
import com.google.ads.interactivemedia.v3.api.AdError

class ErrorHandlingVideoPlayerAdapter(private val videoView: BrightcoveVideoView): ErrorHandlingAnalyticsAdapter(videoView) {

    private val TAG = ErrorHandlingVideoPlayerAdapter::class.java.simpleName

    private val analyticsParams: HashMap<String, String> = HashMap()

    //region Overridden functions
    override fun startTrack(playable: Playable, mode: AnalyticsAdapter.PlayerMode) {
        Log.v(TAG, "startTrack")

        videoView.eventEmitter.on(
            EventType.ERROR
        ) { event ->
            Log.v(TAG, event.type)
            val exception = EXCEPTION_EVENT_PROPERTIES to event.properties[Event.ERROR].toString()
            val message = STRING_MESSAGE_PROPERTIES to ((event.properties[Event.ERROR_MESSAGE] as? String) ?: "")
            val video = VIDEO_EVENT_PROPERTIES to ((event.properties[Event.VIDEO] as? Video) ?: "")
            val source = SOURCE_EVENT_PROPERTIES to ((event.properties[Event.SOURCE] as? Source) ?: "")
            val errorCode = ERROR_CODE to (event.properties["error_code"] as? String ?: "")

            // Put all collected params into map
            analyticsParams.run {
                putAll(collectPlayableProperties(playable, mode))
                putAll(completionParams(playable, isCompleted()))
                exception.run { put(first, second) }
                message.run { put(first, second) }
                video.run { put(first, second.toString()) }
                source.run { put(first, second.toString()) }
                errorCode.run { put(first, second) }
            }

            // Send collected data to analytics agent
            AnalyticsAgentUtil.logTimedEvent(
                playable.videoPlayErrorEvent,
                analyticsParams
            )

            //Check if error type is not AdError
            if (
                event.properties.containsKey(EventType.ERROR)
                && event.properties[EventType.ERROR] !is AdError
            ) {
                videoView.eventEmitter.emit(playable.videoPlayErrorEvent)
            }
        }
    }

    //endregion

    //region Private functions
    /**
     *  Collects all playable properties and return array of Pair<String, String>
     */
    private fun collectPlayableProperties(playable: Playable, mode: AnalyticsAdapter.PlayerMode) =
            arrayOf(
                viewParams(mode),
                priceParams(playable),
                getDataParams(playable),
                getItemName(playable),
                getItemDuration(),
                getItemLink(playable),
                getVodType(playable),
                getVideoPlayerPlugin()
            )


    /**
     *  Video play error event name
     */
    private val Playable.videoPlayErrorEvent: String
        get() = "Video Play Error"

    //endregion


    companion object {
        const val EXCEPTION_EVENT_PROPERTIES = "Exception Event Properties"
        const val STRING_MESSAGE_PROPERTIES = "String Message Properties"
        const val VIDEO_EVENT_PROPERTIES = "Video Event Properties"
        const val SOURCE_EVENT_PROPERTIES = "Source Event Properties"
    }
}