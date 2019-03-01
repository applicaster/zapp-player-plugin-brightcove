package com.applicaster.player.plugins.brightcove

import android.net.Uri
import android.os.Bundle
import android.support.v7.app.AppCompatActivity
import android.view.View
import com.applicaster.player.plugins.brightcove.analytics.AnalyticsAdapter.PlayerMode.FULLSCREEN
import com.applicaster.player.plugins.brightcove.R.integer
import com.applicaster.player.plugins.brightcove.ad.AdsAdapter
import com.applicaster.player.plugins.brightcove.ad.GoogleIMAAdapter
import com.applicaster.player.plugins.brightcove.analytics.*
import com.applicaster.plugin_manager.playersmanager.Playable
import com.applicaster.plugin_manager.playersmanager.internal.PlayersManager
import com.brightcove.player.event.EventType
import com.brightcove.player.view.BrightcoveVideoView
import kotlinx.android.synthetic.main.activity_brightcove_player.*

class BrightcovePlayerActivity : AppCompatActivity(), ErrorDialogListener {

    private lateinit var playable: Playable
    private lateinit var videoView: BrightcoveVideoView
    private lateinit var analyticsAdapter: AnalyticsAdapter
    private lateinit var adAnalyticsAdapter: AdAnalyticsAdapter
    private lateinit var errorHandlingAnalyticsAdapter: ErrorHandlingAnalyticsAdapter
    private lateinit var errorHandlingVideoPlayerAdapter: ErrorHandlingVideoPlayerAdapter
    private var errorDialog: ErrorDialog? = null
    private var videoCompletionResult: VideoCompletionResult = VideoCompletionResult.UNDEFINED
    private var isVideoPaused: Boolean = false
    private var isErrorDialogVisible: Boolean = false

    private lateinit var adsAdapter: AdsAdapter

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        playable = intent.extras!!.getSerializable(BrightcovePlayerAdapter.KEY_PLAYABLE) as Playable

        // inject layout
        setContentView(R.layout.activity_brightcove_player)
        // setupForVideo video view
        configureVideo()
    }

    private fun configureVideo() {
        videoView = with(fullscreen_video_view) {
            post { reconfigureControls() }
            eventEmitter.emit(EventType.ENTER_FULL_SCREEN)
            eventEmitter.on(EventType.COMPLETED) {
                if (videoCompletionResult == VideoCompletionResult.UNDEFINED) {
                    if (!adsAdapter.isPostrollSetUp()) {finish()}
                }
                videoCompletionResult = VideoCompletionResult.COMPLETED
            }

            eventEmitter.on(EventType.AD_COMPLETED) {
                if (videoCompletionResult == VideoCompletionResult.COMPLETED) {
                    videoCompletionResult = VideoCompletionResult.UNDEFINED
                    finish()
                }
            }

            eventEmitter.on(EventType.AD_ERROR) {
                if (videoCompletionResult == VideoCompletionResult.COMPLETED)
                    finish()
            }

            setVideoURI(Uri.parse(playable.contentVideoURL))
            this
        }
        // setupForVideo close btn
        with(fullscreen_close) {
            videoView.eventEmitter.on("didShowMediaControls") { visibility = View.VISIBLE }
            videoView.eventEmitter.on("didHideMediaControls") { visibility = View.GONE }
            setOnClickListener { finish() }
        }

        // initialize tools
        analyticsAdapter = MorpheusAnalyticsAdapter(videoView)
        adAnalyticsAdapter = AdAnalyticsAdapter(videoView)
        errorHandlingAnalyticsAdapter = ErrorHandlingAnalyticsAdapter(videoView)
        errorHandlingVideoPlayerAdapter = ErrorHandlingVideoPlayerAdapter(videoView)
        analyticsAdapter.startTrack(playable, FULLSCREEN)
        adAnalyticsAdapter.startTrack(playable, FULLSCREEN)
        errorHandlingAnalyticsAdapter.startTrack(playable, FULLSCREEN)
        errorHandlingVideoPlayerAdapter.startTrack(playable, FULLSCREEN)
        adsAdapter = GoogleIMAAdapter(videoView)
        adsAdapter.setupForVideo(playable)
    }

    override fun onStart() {
        super.onStart()
        videoView.start()
        videoView.listenVideoPlayError()
    }

    override fun onResume() {
        super.onResume()
        if (this::adsAdapter.isInitialized) {
            adsAdapter.resumePlayingAd()
        }
    }

    override fun onPause() {
        if (this::adsAdapter.isInitialized) {
            adsAdapter.pausePlayingAd()
        }
        super.onPause()
    }

    override fun onDestroy() {
        super.onDestroy()
        analyticsAdapter.endTrack(playable, FULLSCREEN)
        adAnalyticsAdapter.endTrack(playable, FULLSCREEN)
        errorHandlingAnalyticsAdapter.endTrack(playable, FULLSCREEN)
        errorHandlingVideoPlayerAdapter.endTrack(playable, FULLSCREEN)
    }

    private fun BrightcoveVideoView.listenVideoPlayError() {
        videoView.eventEmitter.on(
            "Video Play Error"
        ) {
            if (errorDialog == null || !isErrorDialogVisible) {
                isErrorDialogVisible = true
                adsAdapter.pausePlayingAd()
                if (videoView.isPlaying) {
                    videoView.pause()
                    isVideoPaused = true
                }
                errorDialog = ErrorDialog.newInstance(PlayersManager.getCurrentPlayer().pluginConfigurationParams)
                errorDialog?.show(supportFragmentManager, "ErrorDialog")
            }
        }
    }

    override fun onRefresh() {
        if (errorDialog?.isConnectionEstablished() == true) {
            errorDialog?.dismiss()
            if (isVideoPaused) {
                videoView.start()
            } else {
                videoView.start()
                configureVideo()
            }
            isVideoPaused = false
            isErrorDialogVisible = false
        }
    }

    override fun onBack() {
        errorDialog?.dismiss()
        finish()
    }

    private fun BrightcoveVideoView.reconfigureControls() {
        eventEmitter.emit(
                "seekControllerConfiguration",
                mapOf("seekDefault" to resources.getInteger(integer.brightcove_rewind_interval))
        )
    }

    override fun onBackPressed() {
        super.onBackPressed()
        adAnalyticsAdapter.backPressed(playable)
    }

    enum class VideoCompletionResult {
        COMPLETED,
        UNDEFINED
    }
}
