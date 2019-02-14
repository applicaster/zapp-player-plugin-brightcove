//
//  AdAnalytic.swift
//  BrightcovePlayerPlugin
//
//  Created by Roman Karpievich on 1/21/19.
//

import Foundation

struct AdAnalytic {
    
    var videoAdType = AdTypes.preroll
    var adProvider = AdvertisingProvider.ima
    var adUnit = ""
    var skippable = false
    var skipped = Skipped.unspecified
    var videoDuration = ""
    var adBreakTime = ""
    var midrollInterval = ""
    var adBreakDuration = ""
    var exitMethod = AdExitTypes.unspecified
    var exitTime = ""
    var adServerError = "N/A"
    var clicked = false
    var itemName = ""
    var itemID = ""
    var vodType = VodType.atom
    var itemPriceType = ItemPriceType.free
    var adBreakPercentileTime = ""
    
    var dictionary: [AnyHashable: Any] {
        let skippable = self.skippable ? "Yes" : "No"
        let clicked = self.clicked ? "Yes" : "No"
        return [videoAdType.key: videoAdType.rawValue,
                adProvider.key: adProvider.rawValue,
                "Ad Unit": adUnit,
                "Skippable": skippable,
                skipped.key: skipped.rawValue,
                "Content Video Duration": videoDuration,
                "Ad Break Time": adBreakTime,
                "Midroll Interval": midrollInterval,
                "Ad Break Duration": adBreakDuration,
                exitMethod.key: exitMethod.rawValue,
                "Time When Exited": exitTime,
                "Ad Server Error": adServerError,
                "Clicked": clicked,
                "Item Name": itemName,
                "Item ID": itemID,
                vodType.key: vodType.rawValue,
                itemPriceType.key: itemPriceType.rawValue,
                "Ad Break Percentile Time": adBreakPercentileTime ]
    }
}
