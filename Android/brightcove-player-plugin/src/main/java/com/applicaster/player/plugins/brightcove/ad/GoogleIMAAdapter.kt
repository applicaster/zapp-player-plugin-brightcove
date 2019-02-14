package com.applicaster.player.plugins.brightcove.ad

import android.text.format.DateUtils
import android.util.Log
import com.brightcove.ima.GoogleIMAComponent
import com.brightcove.ima.GoogleIMAEventType
import com.brightcove.player.event.Event
import com.brightcove.player.event.EventType
import com.brightcove.player.model.CuePoint
import com.brightcove.player.view.BrightcoveVideoView
import com.google.ads.interactivemedia.v3.api.AdsRequest
import com.google.ads.interactivemedia.v3.api.ImaSdkFactory
import java.util.HashMap
import kotlin.collections.ArrayList
import kotlin.collections.set
import kotlin.math.roundToInt

class GoogleIMAAdapter(private val videoView: BrightcoveVideoView) :
        VideoAdsAdapter(videoView) {
    private lateinit var googleIMAComponent: GoogleIMAComponent
    private var currentQuePoint: CuePoint? = null

    override fun setupAdsPlugin() {
        setupGoogleIMA()
    }

    /**
     * Setup the Brightcove IMA Plugin
     */
    private fun setupGoogleIMA() {
        val ads = getAds()
        if (ads.isNotEmpty()) {
            val adType = ads[0].getAdType()
            // Establish the Google IMA SDK factory instance.
            val sdkFactory = ImaSdkFactory.getInstance()

            // Defer adding cue points until the set video event is triggered.
            getEventEmitter().on(
                    EventType.DID_SET_SOURCE
            ) { event ->
                Log.v(TAG, event.type)
                /**
                 * For VAST ad we should manually add cue points
                 * @see VideoAd.AdType for more info about ad types
                 */
                if (adType == VideoAd.AdType.VAST) {
                    setupCuePoints(ads)
                }
            }

            // Enable logging of ads request for video
            getEventEmitter().on(
                GoogleIMAEventType.ADS_REQUEST_FOR_VIDEO
            ) {
                event -> Log.v(TAG, event.type)
                if (adType == VideoAd.AdType.VAST) {
                    val propsList = event.properties["cue_points"] as? ArrayList<CuePoint>
                    currentQuePoint = propsList?.get(0)
                }
            }

            // Enable logging of ad starts
            getEventEmitter().on(
                    EventType.AD_STARTED
            ) { event -> Log.v(TAG, event.type) }

            // Enable logging of any failed attempts to play an ad.
            getEventEmitter().on(
                GoogleIMAEventType.DID_FAIL_TO_PLAY_AD
            ) {
                event -> Log.v(TAG, event.type)
                if (adType == VideoAd.AdType.VAST) {
                    getMediaController().brightcoveSeekBar.removeMarker(currentQuePoint?.position)
                    currentQuePoint = null
                }
            }

            // Enable logging of ad completions.
            getEventEmitter().on(
                    EventType.AD_COMPLETED
            ) { event -> Log.v(TAG, event.type) }

            // Set up a listener for initializing AdsRequests. The Google IMA plugin emits an ad
            // request event in response to each cue point event.  The event processor (handler)
            // illustrates how to play ads back to back.
            getEventEmitter().on(GoogleIMAEventType.ADS_REQUEST_FOR_VIDEO) { event ->
                // Create a container object for the ads to be presented.
                val container = sdkFactory.createAdDisplayContainer()
                container.player = googleIMAComponent.videoAdPlayer
                container.adContainer = videoView

                // Build the list of ads request objects, one per ad
                // URL, and point each to the ad display container
                // created above.
                val adsRequests = ArrayList<AdsRequest>()
                val adUrls = setupAdUrlsForEvent(adType, event, ads)

                for (adUrl in adUrls) {
                    val adsRequest = sdkFactory.createAdsRequest()
                    adsRequest.adTagUrl = adUrl
                    adsRequest.adDisplayContainer = container
                    adsRequests.add(adsRequest)
                }

                // Respond to the event with the new ad requests.
                event.properties[GoogleIMAComponent.ADS_REQUESTS] = adsRequests
                videoView.eventEmitter.respond(event)
            }


            /**
             *Create the Brightcove IMA Plugin and register the event emitter so that the plugin
             * can deal with video events.
             * @see VideoAd.AdType for more info about ad types
             */
            googleIMAComponent = when (adType) {
                VideoAd.AdType.VMAP ->
                    GoogleIMAComponent(videoView, getEventEmitter(), true)
                VideoAd.AdType.VAST -> GoogleIMAComponent(videoView, getEventEmitter())
            }

        }
    }

    /**
     * For VAST ad we need to manually setup cue points (place when add will be played)
     */
    private fun setupCuePoints(source: List<VideoAd>) {
        val cuePointType = CUE_POINT_AD_TYPE
        val details = HashMap<String, Any>()
        var cuePoint: CuePoint

        for (ad: VideoAd in source) {
            if (ad.getAdType() == VideoAd.AdType.VAST) {
                val properties = HashMap<String, Any>()
                properties[CUE_POINT_URL_KEY] = ad.adUrl
                cuePoint = createCuePoint(ad.offset!!, cuePointType, properties)
                details[Event.CUE_POINT] = cuePoint
                getEventEmitter().emit(EventType.SET_CUE_POINT, details)
            }
        }
    }


    /**
     * Creating cue point based on offset value
     */
    private fun createCuePoint(offset: String, cuePointType: String, properties: HashMap<String, Any>): CuePoint {
        return when (offset) {
            "preroll" -> {
                CuePoint(CuePoint.PositionType.BEFORE, cuePointType, properties)
            }
            "postroll" -> {
                CuePoint(CuePoint.PositionType.AFTER, cuePointType, properties)
            }
            else -> {
                val cuepointTime = offset.toFloat().roundToInt() * DateUtils.SECOND_IN_MILLIS.toInt()
                // Add a marker where the ad will be.
                getMediaController().brightcoveSeekBar.addMarker(cuepointTime)
                CuePoint(cuepointTime, cuePointType, properties)
            }
        }
    }

    /**
     * Obtaining list of ad URLs to show
     * For VAST we need to obtain info from cue points
     * For VMAP just get data from incoming ad
     */
    private fun setupAdUrlsForEvent(
            adType: VideoAd.AdType,
            event: Event,
            ads: List<VideoAd>
    ): ArrayList<String> {
        val adsToShow = ArrayList<String>()

        when (adType) {
            VideoAd.AdType.VAST -> {
                val cuePoints = event.properties["cue_points"] as ArrayList<CuePoint>
                for (cuePoint in cuePoints) {
                    if (cuePoint.type == CUE_POINT_AD_TYPE)
                        adsToShow.add(cuePoint.properties[CUE_POINT_URL_KEY] as String)
                }
            }
            VideoAd.AdType.VMAP -> {
                for (ad in ads) {
                    adsToShow.add(ad.adUrl)
                }
            }
        }
        return adsToShow
    }

    companion object {
        private val TAG = VideoAdsAdapter::class.java.simpleName
        private const val CUE_POINT_AD_TYPE = "ad"
        private const val CUE_POINT_URL_KEY = "url"
    }
}
