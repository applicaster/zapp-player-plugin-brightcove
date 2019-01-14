package com.applicaster.player.plugins.brightcove.ad

import com.google.gson.annotations.SerializedName

data class VideoAd(
        @SerializedName("ad_url") val adUrl: String,
        @SerializedName("offset") val offset: String?
) {

    /**
     * If there is offset value - it's VAST, otherwise it's VMAP
     */
    fun getAdType(): AdType {
        return when {
            offset != null && offset.isNotEmpty() -> AdType.VAST
            else -> AdType.VMAP
        }
    }

    /**
     * For VAST ad we should manually add CuePoints according to obtained offset value:
     * "pre" - Preroll (launches before video player opens)
     * "post" - Postroll (launches as video player closes)
     * int value - Midroll (renders at specified timecode or percentile within the video content)
     * For VMAP this behavior should be handled by the IMA plugin, according to the marks in ad URL
     */
    enum class AdType {
        VMAP,
        VAST
    }
}

data class VideoAdContainer(
        @SerializedName("video_ad") val videoAds: List<VideoAd>
)

