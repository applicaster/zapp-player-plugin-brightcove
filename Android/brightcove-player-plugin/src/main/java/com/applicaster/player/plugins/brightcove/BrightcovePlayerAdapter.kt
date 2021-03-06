package com.applicaster.player.plugins.brightcove

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.support.v4.app.Fragment
import android.support.v7.app.AppCompatActivity
import android.view.ViewGroup
import com.applicaster.analytics.AnalyticsAgentUtil
import com.applicaster.atom.model.APAtomEntry
import com.applicaster.player.VideoAdsUtil
import com.applicaster.player.defaultplayer.BasePlayer
import com.applicaster.player.plugins.brightcove.analytics.AnalyticsAdapter.PlayerMode.INLINE
import com.applicaster.player.plugins.brightcove.ad.AdsAdapter
import com.applicaster.player.plugins.brightcove.ad.GoogleIMAAdapter
import com.applicaster.player.plugins.brightcove.analytics.*
import com.applicaster.player.plugins.brightcove.captions.CaptionsAdapter
import com.applicaster.plugin_manager.playersmanager.AdsConfiguration
import com.applicaster.plugin_manager.playersmanager.Playable
import com.applicaster.plugin_manager.playersmanager.PlayableConfiguration
import com.applicaster.plugin_manager.playersmanager.PlayerContract
import com.applicaster.plugin_manager.screen.PluginScreen
import com.brightcove.player.view.BrightcoveExoPlayerVideoView
import java.io.Serializable
import java.util.HashMap

/**
 * BrightcovePlayerAdapter:
 * This adapter extends the BasePlayer class which implements the PlayerContract.
 * This class includes the various initialization methods as well as several playback methods.
 */
class BrightcovePlayerAdapter : BasePlayer(), ErrorDialogListener, PluginScreen {

    private lateinit var videoView: BrightcoveExoPlayerVideoView
    private lateinit var adAnalyticsAdapter: AdAnalyticsAdapter
    private lateinit var analyticsAdapter: AnalyticsAdapter
    private lateinit var errorHandlingAnalyticsAdapter: ErrorHandlingAnalyticsAdapter
    private lateinit var errorHandlingVideoPlayerAdapter: ErrorHandlingVideoPlayerAdapter
    private lateinit var completeAnalyticsAdapter: CompleteAnalyticsAdapter
    private lateinit var adsAdapter: AdsAdapter
    private lateinit var viewGroup: ViewGroup
    private var errorDialog: ErrorDialog? = null
    private var isErrorDialogVisible: Boolean = false

    /**
     * initialization of the player instance with a playable item
     */
    override fun init(playable: Playable, context: Context) {
        this.init(listOf(playable), context)
    }

    /**
     * initialization of the player instance with  multiple playable items
     */
    override fun init(playList: List<Playable>, context: Context) {
        super.init(playList, context)
        videoView = BrightcoveExoPlayerVideoView(context)
        analyticsAdapter = MorpheusAnalyticsAdapter(videoView)
        adAnalyticsAdapter = AdAnalyticsAdapter(videoView)
        errorHandlingAnalyticsAdapter = ErrorHandlingAnalyticsAdapter(videoView)
        errorHandlingVideoPlayerAdapter = ErrorHandlingVideoPlayerAdapter(videoView)
        completeAnalyticsAdapter = CompleteAnalyticsAdapter(videoView)
        adsAdapter = GoogleIMAAdapter(videoView)
    }

    /**
     * start the player in fullscreen with configuration.
     *
     * @param playableConfiguration player configuration.
     * @param requestCode request code if needed - if not send NO_REQUEST_CODE instead.
     */
    override fun playInFullscreen(
            playableConfiguration: PlayableConfiguration?, requestCode: Int,
            context: Context
    ) {
        super.playInFullscreen(playableConfiguration, requestCode, context)
        val intent = Intent(context, BrightcovePlayerActivity::class.java)
        firstPlayable.also {
            intent.putExtra(KEY_PLAYABLE, it)
            intent.flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
            context.startActivity(intent)
        }
    }

    /**
     * Add the player into the given container.
     *
     * @param viewGroup The container the player should be added to
     */
    override fun attachInline(viewGroup: ViewGroup) {
        super.attachInline(viewGroup)
        viewGroup.addView(videoView)
        videoView.finishInitialization()
        this.viewGroup = viewGroup
        //
        adsAdapter.setupForVideo(firstPlayable)
        analyticsAdapter.startTrack(firstPlayable, INLINE)
        adAnalyticsAdapter.startTrack(firstPlayable, INLINE)
        errorHandlingAnalyticsAdapter.startTrack(firstPlayable, INLINE)
        errorHandlingVideoPlayerAdapter.startTrack(firstPlayable, INLINE)
        completeAnalyticsAdapter.startTrack(firstPlayable, INLINE)
        listenVideoPlayError()
    }

    /**
     * Remove the player from it's container.
     *
     * @param viewGroup The container that the player is attached to
     */
    override fun removeInline(viewGroup: ViewGroup) {
        super.removeInline(viewGroup)
        viewGroup.removeView(videoView)
        //
        analyticsAdapter.endTrack(firstPlayable, INLINE)
        adAnalyticsAdapter.endTrack(firstPlayable, INLINE)
        errorHandlingAnalyticsAdapter.endTrack(firstPlayable, INLINE)
        errorHandlingVideoPlayerAdapter.endTrack(firstPlayable, INLINE)
        completeAnalyticsAdapter.endTrack(firstPlayable, INLINE)
    }

    /**
     * start the player in inline with configuration.
     */
    override fun playInline(configuration: PlayableConfiguration?) {
        super.playInline(configuration)
        firstPlayable.also {
            videoView.setVideoURI(Uri.parse(it.contentVideoURL))
            CaptionsAdapter(videoView).apply {
                setupForVideo(firstPlayable)
                initAnalytics(firstPlayable, INLINE)
            }
            videoView.start()
        }
    }

    /**
     * Stops playing the inline player.
     */
    override fun stopInline() {
        super.stopInline()
        videoView.stopPlayback()
    }

    /**
     * Pauses playing the inline player
     */
    override fun pauseInline() {
        super.pauseInline()
        if (this::adsAdapter.isInitialized) {
            (adsAdapter as GoogleIMAAdapter).pausePlayingAd()
        }
        if (videoView != null && videoView.isPlaying)
            videoView.pause()
    }

    /**
     * Resumes playing the inline player.
     */
    override fun resumeInline() {
        super.resumeInline()
        videoView.start()
        if (this::adsAdapter.isInitialized) {
            (adsAdapter as GoogleIMAAdapter).resumePlayingAd()
        }
    }

    override fun onRefresh() {
        if (errorDialog?.isConnectionEstablished() == true) {
            errorDialog?.dismiss()
            videoView.start()
            isErrorDialogVisible = false
        }
    }

    override fun onBack() {
        errorDialog?.dismiss()
        removeInline(viewGroup)
    }

    private fun listenVideoPlayError() {
        videoView.eventEmitter.on(
            "Video Play Error"
        ) {
            if (errorDialog == null || !isErrorDialogVisible) {
                isErrorDialogVisible = true
                errorDialog = ErrorDialog.newInstance(this.pluginConfigurationParams)
                errorDialog?.setOnErrorDialogListener(this)
                errorDialog?.show((this.context as? AppCompatActivity)?.supportFragmentManager, "ErrorDialog")
            }
        }
    }

    override fun generateFragment(screenMap: HashMap<String, Any>?, dataSource: Serializable?): Fragment? {
        return null
    }

    override fun present(
        context: Context?,
        screenMap: HashMap<String, Any>?,
        dataSource: Serializable?,
        isActivity: Boolean
    ) {
        val playable = (dataSource as APAtomEntry).playable

        val atomAdsConfiguration = AdsConfiguration()
        atomAdsConfiguration.categoryId = screenMap?.get(CELL_SHOW_ID_EXTENSION_KEY).toString()
        atomAdsConfiguration.extensionName = VideoAdsUtil.getPrerollExtension(playable.isLive, false)
        atomAdsConfiguration.screenType = AnalyticsAgentUtil.ATOM_VIDEO_ARTICLE
        atomAdsConfiguration.analyticsScreenName = screenMap?.get(SCREEN_NAME).toString()

        VideoAdsUtil.playAdVideo(context, playable, PlayerContract.NO_REQUEST_CODE, atomAdsConfiguration)
    }

    companion object {
        internal const val KEY_PLAYABLE = "playable"
        private val CELL_SHOW_ID_EXTENSION_KEY = "cell show id"
        private val SCREEN_NAME = "screen_name"
    }
}
