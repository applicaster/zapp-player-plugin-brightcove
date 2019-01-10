package com.applicaster.player.plugins.brightcove.ad

import com.google.gson.*
import java.lang.reflect.Type

class AdTypeAdapter : JsonDeserializer<VideoAdContainer> {
    override fun deserialize(json: JsonElement, typeOfT: Type, ctx: JsonDeserializationContext): VideoAdContainer {
        val ads = ArrayList<VideoAd>()
        val adsData = (json as JsonObject).get("video_ad")
        when (adsData) {
            is JsonArray -> {
                for (ad in adsData) {
                    ads.add(ctx.deserialize<Any>(ad, VideoAd::class.java) as VideoAd)
                }
            }
            is JsonObject -> {
                ads.add(ctx.deserialize<Any>(adsData, VideoAd::class.java) as VideoAd)
            }
        }
        return VideoAdContainer(ads)
    }
}
