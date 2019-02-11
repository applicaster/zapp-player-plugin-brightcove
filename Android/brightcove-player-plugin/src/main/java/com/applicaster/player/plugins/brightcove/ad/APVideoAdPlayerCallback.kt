package com.applicaster.player.plugins.brightcove.ad

import com.google.ads.interactivemedia.v3.api.player.VideoAdPlayer

abstract class APVideoAdPlayerCallback : VideoAdPlayer.VideoAdPlayerCallback {
    override fun onVolumeChanged(p0: Int) {}

    override fun onResume() {}

    override fun onPause() { onVideoAdPaused() }

    override fun onError() {}

    override fun onEnded() { onVideoAdEnded() }

    override fun onPlay() {}

    abstract fun onVideoAdPaused()
    abstract fun onVideoAdEnded()
}