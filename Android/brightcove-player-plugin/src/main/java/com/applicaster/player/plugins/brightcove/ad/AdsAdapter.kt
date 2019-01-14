package com.applicaster.player.plugins.brightcove.ad

import com.applicaster.atom.model.APAtomEntry
import com.applicaster.plugin_manager.playersmanager.Playable
import com.brightcove.player.event.EventEmitter
import com.brightcove.player.mediacontroller.BrightcoveMediaController
import com.brightcove.player.view.BrightcoveVideoView
import com.google.gson.GsonBuilder
import com.google.gson.reflect.TypeToken


interface AdsAdapter {
    fun setupForVideo(playable: Playable)
}

abstract class VideoAdsAdapter(private val videoView: BrightcoveVideoView) :
        AdsAdapter {

    private lateinit var mediaController: BrightcoveMediaController
    private lateinit var eventEmitter: EventEmitter
    private var ads: List<VideoAd> = ArrayList()

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
            // data could be returned in array or in object, so need to handle it using type adapter
            val gson = GsonBuilder()
                    .registerTypeAdapter(object : TypeToken<VideoAdContainer>() {}.type, AdTypeAdapter())
                    .create()
            val adsExtension = playable.entry.getExtension("video_ads", String::class.java)
            ads = gson.fromJson(adsExtension, VideoAdContainer::class.java).videoAds
        }
    }

    protected fun getMediaController() = mediaController
    protected fun getEventEmitter() = eventEmitter
    protected fun getAds() = ads

    protected abstract fun setupAdsPlugin()
}

