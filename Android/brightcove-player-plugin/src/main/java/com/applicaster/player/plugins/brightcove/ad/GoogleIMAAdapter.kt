package com.applicaster.player.plugins.brightcove.ad

import android.text.format.DateUtils
import android.util.Log
import com.brightcove.ima.GoogleIMAComponent
import com.brightcove.ima.GoogleIMAEventType
import com.brightcove.ima.GoogleIMAVideoAdPlayer
import com.brightcove.player.event.Event
import com.brightcove.player.event.EventType
import com.brightcove.player.model.CuePoint
import com.brightcove.player.view.BrightcoveVideoView
import com.google.ads.interactivemedia.v3.api.*
import java.util.HashMap
import kotlin.collections.ArrayList
import kotlin.collections.set
import kotlin.math.roundToInt

class GoogleIMAAdapter(private val videoView: BrightcoveVideoView) :
        VideoAdsAdapter(videoView) {
    private var googleIMAComponent: GoogleIMAComponent? = null
    private var currentQuePoint: CuePoint? = null
    private var vmapCuePoints: MutableList<Float>? = null

    private var savedCurrentVideoAdPosition: Int = 0
    private var container: AdDisplayContainer? = null
    private var isPostrollSetUp: Boolean = false
    private var isVideoPlayFailed: Boolean = false
    private var adsManager: AdsManager? = null

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
                videoView.start()
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
            ) { event ->
                Log.v(TAG, event.type)
                if (adType == VideoAd.AdType.VAST) {
                    val propsList = event.properties["cue_points"] as? ArrayList<CuePoint>
                    currentQuePoint = propsList?.get(0)
                }
            }

            // Enable logging of any failed attempts to play an ad.
            getEventEmitter().on(
                GoogleIMAEventType.DID_FAIL_TO_PLAY_AD
            ) { event ->
                Log.v(TAG, event.type)
                if (adType == VideoAd.AdType.VAST) {
                    when (currentQuePoint?.positionType) {
                        CuePoint.PositionType.POINT_IN_TIME -> {
                            getMediaController().brightcoveSeekBar.removeMarker(currentQuePoint?.position)
                            currentQuePoint = null
                        }
                        else -> {}
                    }
                } else {
                    removeAdTimeMarker(videoView.currentPosition)
                }
            }

            getEventEmitter().on(
                GoogleIMAEventType.ADS_MANAGER_LOADED
            ) { event ->
                adsManager = event.properties["adsManager"] as? AdsManager?
                if (isVideoPlayFailed) adsManager?.destroy()
                isVideoPlayFailed = false
                if (adType == VideoAd.AdType.VMAP) {
                    vmapCuePoints = adsManager?.adCuePoints
                }
            }

            // If video play error occurred we should remove ad views
            getEventEmitter().on("Video Play Error") {
                isVideoPlayFailed = true
            }

            // Enable logging of ad completions.
            getEventEmitter().on(EventType.AD_COMPLETED) { isVideoPlayFailed = false }


            // Set up a listener for initializing AdsRequests. The Google IMA plugin emits an ad
            // request event in response to each cue point event.  The event processor (handler)
            // illustrates how to play ads back to back.
            getEventEmitter().on(GoogleIMAEventType.ADS_REQUEST_FOR_VIDEO) { event ->
                // Create a container object for the ads to be presented.
                container = sdkFactory.createAdDisplayContainer()
                container?.player = googleIMAComponent?.videoAdPlayer
                container?.adContainer = videoView

                container?.player?.addCallback(object : APVideoAdPlayerCallback() {
                    override fun onVideoAdPaused() {
                        val player: GoogleIMAVideoAdPlayer? = container?.player as? GoogleIMAVideoAdPlayer
                        savedCurrentVideoAdPosition = player?.currentPosition ?: 0
                    }

                    override fun onVideoAdEnded() {
                        savedCurrentVideoAdPosition = 0
                    }
                })

                // Build the list of ads request objects, one per ad
                // URL, and point each to the ad display container
                // created above.
                val adsRequests = ArrayList<AdsRequest>()
                val adUrls = setupAdUrlsForEvent(adType, event, ads)

                val adsRequest = sdkFactory.createAdsRequest()
                for (adUrl in adUrls) {
                    adsRequest.adTagUrl = adUrl
                    adsRequests.add(adsRequest)
                }
                adsRequest.adDisplayContainer = container

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
     * Resume playing ad.
     * This one starts playing ad from the beginning.
     * It is not possible to start playing ad from paused time.
     */
    override fun resumePlayingAd() {
        if (container != null) {
            val player: GoogleIMAVideoAdPlayer? = container?.player as? GoogleIMAVideoAdPlayer
            player?.seekTo(savedCurrentVideoAdPosition)
            player?.playAd()
        }
    }

    /**
     * Pause playing ad and save video playing position
     */
    override fun pausePlayingAd() {
        if (container != null) {
            val player: GoogleIMAVideoAdPlayer? = container?.player as? GoogleIMAVideoAdPlayer
            if (player?.isPlaying == true)
                savedCurrentVideoAdPosition = player.currentPosition
        }
    }

    /**
     * Check if advertisement have postrolls.
     */
    override fun isPostrollSetUp(): Boolean {
        var result = false
        if (isPostrollSetUp) {
            result = true
        }
        if (vmapCuePoints != null) {
            vmapCuePoints?.forEach {
                if (it < 0 || ((it * 1000f).toInt() >= videoView.duration))
                    result = true
            }
        }
        return result
    }

    /**
     * Remove time marker from time line if advertisement playing was corrupted.
     * Used for VMAP format.
     */
    private fun removeAdTimeMarker(currentVideoPosition: Int) {
        var result = 0f
        vmapCuePoints?.forEach {
            if (it > 0.0f && result == 0f) {
                val currentVideoPositionInSec = currentVideoPosition.toFloat() / 1000f
                var timeDiff = currentVideoPositionInSec - it
                result = (currentVideoPositionInSec - timeDiff) * 1000
                timeDiff *= 1000f
                if (result.toInt() == currentVideoPosition - Math.abs(timeDiff.roundToInt()))
                    getMediaController().brightcoveSeekBar.removeMarker(result.toInt())
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
                isPostrollSetUp = true
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
