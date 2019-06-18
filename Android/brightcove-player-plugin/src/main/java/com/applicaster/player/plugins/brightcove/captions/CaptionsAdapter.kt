package com.applicaster.player.plugins.brightcove.captions

import android.net.Uri
import android.util.Log
import com.applicaster.atom.model.APAtomEntry
import com.applicaster.player.plugins.brightcove.analytics.AnalyticsAdapter
import com.applicaster.player.plugins.brightcove.analytics.CaptionsAnalyticsAdapter
import com.applicaster.plugin_manager.playersmanager.Playable
import com.brightcove.player.captioning.BrightcoveCaptionFormat
import com.brightcove.player.event.EventEmitter
import com.brightcove.player.event.EventType
import com.brightcove.player.view.BrightcoveVideoView
import java.util.*

class CaptionsAdapter(private val videoView: BrightcoveVideoView) {

    private val TAG = CaptionsAdapter::class.java.canonicalName
    private val KEY_CAPTIONS_EXTENSION = "text_tracks"
    private val KEY_TRACKS = "tracks"
    private val KEY_LABEL = "label"
    private val KEY_KIND = "kind"
    private val KEY_TYPE = "type"
    private val KEY_LANGUAGE = "language"
    private val KEY_SRC = "source"
    private lateinit var eventEmitter: EventEmitter
    private lateinit var captionsAnalyticsAdapter: CaptionsAnalyticsAdapter

    fun initAnalytics(playable: Playable, mode: AnalyticsAdapter.PlayerMode) {
        captionsAnalyticsAdapter = CaptionsAnalyticsAdapter(videoView)
        captionsAnalyticsAdapter.startTrack(playable, mode)
    }

    private enum class Kind(val value: String) {
        Captions(value = "captions"),
        Subtitles(value = "subtitles")
    }

    fun setupForVideo(playable: Playable) {
        setupVideoComponents()
        parseCaptions(playable)
        eventEmitter.once(EventType.CAPTIONS_LANGUAGES) {
            videoView.setClosedCaptioningEnabled(true)
            videoView.setSubtitleLocale("en")
        }
    }

    private fun setupVideoComponents() {
        eventEmitter = videoView.eventEmitter
    }

    private fun parseCaptions(playable: Playable) {
        with(playable as? APAtomEntry.APAtomEntryPlayable) {
            val captionsExtension = this?.entry?.getExtension(KEY_CAPTIONS_EXTENSION, Map::class.java)
            val tracksMap: Map<*, *>? = captionsExtension?.takeIf { extension: Map<*, *> ->
                extension.containsKey(KEY_TRACKS)
            }
            val tracksList = tracksMap?.get(KEY_TRACKS) as? List<*>
            tracksList?.forEach { track: Any? ->
                (track as? Map<*, *>)?.let {
                    createCaptions(it)
                }
            }
        }
    }

    private fun createCaptions(track: Map<*, *>) {
        val label: String = track[KEY_LABEL].toString()
        val type: String = track[KEY_TYPE].toString()
        val kind: String = track[KEY_KIND].toString()
        val language: String = track[KEY_LANGUAGE].toString()
        val src: String = track[KEY_SRC].toString()
        val uri: Uri = Uri.parse(src)
        if (kind.toLowerCase(Locale.US) == Kind.Captions.value) {
            val captionFormat = BrightcoveCaptionFormat.createCaptionFormat(type, language)
            videoView.addSubtitleSource(uri, captionFormat)
            Log.d(TAG, "Captions -> label:$label, type:$type, kind:$kind, language:$language, source:$src")
        } else {
            Log.w(TAG, "Incorrect captions format!")
        }
    }
}