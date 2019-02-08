package com.applicaster.player.plugins.brightcove.ad

import android.util.Log
import com.applicaster.atom.model.APAtomEntry
import com.applicaster.plugin_manager.playersmanager.Playable
import com.brightcove.player.event.EventEmitter
import com.brightcove.player.mediacontroller.BrightcoveMediaController
import com.brightcove.player.view.BrightcoveVideoView

interface AdsAdapter {
    fun setupForVideo(playable: Playable)
}

abstract class VideoAdsAdapter(private val videoView: BrightcoveVideoView) :
        AdsAdapter {

    private lateinit var mediaController: BrightcoveMediaController
    private lateinit var eventEmitter: EventEmitter
    private var ads: ArrayList<VideoAd> = ArrayList()

    override fun setupForVideo(playable: Playable) {
        setupVideoComponents()
        parseAds(playable)
        setupAdsPlugin()
    }

    private fun setupVideoComponents() {
        eventEmitter = videoView.eventEmitter
        mediaController = BrightcoveMediaController(videoView)
        videoView.setMediaController(mediaController)
    }

    private fun parseAds(playable: Playable) {
        //If the playable is a reference of type APAtomEntryPlayable get the plugin ID from the extensions
        if (playable is APAtomEntry.APAtomEntryPlayable) {
            Log.d(TAG, "Playable is APAtomEntry.APAtomEntryPlayable")
            Log.d(TAG, "Extensions ${playable.entry.extensions}")

            val adsExtension = playable.entry.getExtension(VideoAd.KEY_VIDEO_AD_EXTENSION, Map::class.java)
            if (adsExtension != null && adsExtension is Map) {
                val videoAd = adsExtension[VideoAd.KEY_AD_CONTAINER]
                // data could be returned in array or in object, so need to handle it using type adapter
                videoAd?.run {
                    when {
                        this is List<*> -> {
                            for (ad in this) {
                                if (ad is Map<*, *>) parseSingleAd(ad)
                            }
                        }
                        this is Map<*, *> -> {
                            parseSingleAd(this)
                        }
                    }
                }
            }
        }
    }

    private fun parseSingleAd(ad: Map<*, *>) {
        var url = ""
        var offset: String? = null
        if (ad.containsKey(VideoAd.KEY_URL)) {
            url = ad[VideoAd.KEY_URL].toString()
        }
        if (ad.containsKey(VideoAd.KEY_OFFSET)) {
            offset = ad[VideoAd.KEY_OFFSET].toString()
        }
        ads.add(VideoAd(url, offset))
    }

    protected fun getMediaController() = mediaController
    protected fun getEventEmitter() = eventEmitter
    protected fun getAds() = ads

    protected abstract fun setupAdsPlugin()

    companion object {
        const val TAG = "VideoAdsAdapter"
    }
}

