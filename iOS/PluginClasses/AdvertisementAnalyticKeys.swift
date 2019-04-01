//
//  AdvertisementAnalyticKeys.swift
//  BrightcovePlayerPlugin
//
//  Created by Roman Karpievich on 1/17/19.
//

import Foundation

enum AdTypes: String {
    case preroll = "Preroll"
    case midroll = "Midroll"
    case postroll = "Postroll"
    
    var key: String {
        return "Video Ad Type"
    }
}

enum AdExitTypes: String {
    case completed = "Completed"
    case skipped = "Skipped"
    case adServerError = "Ad Server Error"
    case closedApp = "Closed App"
    case clicked = "Clicked"
    case unspecified = "Unspecified"
    
    var key: String {
        return "Ad Exit Method"
    }
}

enum Skipped: String {
    case yes = "Yes"
    case no = "No"
    case unspecified = "N/A"
    
    var key: String {
        return "Skipped"
    }
}

enum ItemPriceType: String {
    case free = "Free"
    case paid = "Paid"
    
    var key: String {
        return "Free or Paid Video"
    }
    
    init(fromBool isFree: Bool) {
        if isFree == true {
            self.init(rawValue: "Free")!
        } else {
            self.init(rawValue: "Paid")!
        }
    }
}

enum VodType: String {
    case atom = "ATOM"
    
    static var key: String {
        return "VOD Type"
    }
}

enum VideoPlayerPlugin: String {
    case applicaster = "Applicaster Player"
    case brightcove = "Brightcove Player"
    
    var key: String {
        return "Video Player Plugin"
    }
}

enum AdvertisingProvider: String {
    case ima = "IMA"
    
    var key: String {
        return "Advertising Provider"
    }
}
