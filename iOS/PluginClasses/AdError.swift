//
//  AdError.swift
//  BrightcovePlayerPlugin
//
//  Created by Roman Karpievich on 1/21/19.
//

import Foundation
import GoogleInteractiveMediaAds
import ZappPlugins

struct AdError {
    
    var itemName = ""
    var itemID = ""
    var itemDuration = ""
    var itemLink = ""
    var isCompleted = false
    var itemPriceType = ItemPriceType.free
    var vodType = VodType.atom
    var screenMode = PlayerScreenMode.fullscreen
    
    var videoPlayer = VideoPlayerPlugin.brightcove
    var errorCode = IMAErrorCodes.unknown
    var adProviderErrorType = IMAErrorTypes.adUnknownErrorType
    var adProvider = AdvertisingProvider.ima
    var adErrorMessage = ""
    
    var dictionary: [AnyHashable: Any] {
        let isCompleted = self.isCompleted ? "Yes" : "No"
        return [itemPriceType.key: itemPriceType.rawValue,
                "Item ID": itemID,
                "Item Name": itemName,
                "Item Duration": itemDuration,
                "Item Link": itemLink,
                "Completed": isCompleted,
                vodType.key: vodType.rawValue,
                screenMode.key: screenMode.rawValue,
                videoPlayer.key: videoPlayer.rawValue,
                errorCode.key: errorCode.stringValue(),
                adProvider.key: adProvider.rawValue,
                adProviderErrorType.key: adProviderErrorType.stringValue(),
                "Error Message": adErrorMessage]
    }
    
    init(from imaAdError: IMAAdError, forItem item: ZPPlayable) {
        itemName = item.playableName()
        itemID = "\(item.identifier!)"
        itemLink = item.contentVideoURLPath()
        errorCode = IMAErrorCodes(rawValue: imaAdError.code.rawValue) ?? .unknown
        adProviderErrorType = IMAErrorTypes(rawValue: imaAdError.type.rawValue) ?? .adUnknownErrorType
        adErrorMessage = imaAdError.message
    }
}
