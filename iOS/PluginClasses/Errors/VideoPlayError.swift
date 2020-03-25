//
//  VideoPlayError.swift
//  BrightcovePlayerPlugin
//
//  Created by Roman Karpievich on 1/22/19.
//

import Foundation
import ZappPlugins

struct VideoPlayError {
    
    var itemName = ""
    var itemID = ""
    var itemDuration = ""
    var itemLink = ""
    var isCompleted = false
    var itemPriceType = ItemPriceType.free
    var vodType = VodType.atom
    var screenMode = PlayerScreenMode.fullscreen
    
    var videoPlayer = VideoPlayerPlugin.brightcove
    var errorCode: PlaybackErrors?
    var errorMessage = ""
    var domain = ""
    
    var dictionary: [AnyHashable: Any] {
        let isCompleted = self.isCompleted ? "Yes" : "No"
        return [itemPriceType.key: itemPriceType.rawValue,
                "Item ID": itemID,
                "Item Name": itemName,
                "Item Duration": itemDuration,
                "Item Link": itemLink,
                "Completed": isCompleted,
                VodType.key: vodType.rawValue,
                screenMode.key: screenMode.rawValue,
                videoPlayer.key: videoPlayer.rawValue,
                errorCode!.key: errorCode!.value,
                "Error Message": errorMessage,
                "Error Domain": domain]
    }
    
    init(from error: NSError, forItem item: ZPPlayable) {
        itemName = item.playableName()
        itemID = "\(item.identifier!)"
        itemLink = item.contentVideoURLPath()
        itemPriceType = ItemPriceType(fromBool: item.isFree)
        
        errorCode = PlaybackErrors(rawValue: error.code)
        errorMessage = error.localizedDescription
        domain = error.domain
    }
}
