//
//  AdvertisementParser.swift
//  BrightcovePlayerPlugin
//
//  Created by Roman Karpievich on 1/9/19.
//

import Foundation

enum Advertisement {
    case vast([VastAdvertisement])
    case vmap(String)
    case none
}

enum VastAdvertisement {
    case preRoll(String)
    case postRoll(String)
    case timeline(String, Int)
}

enum VideoExtensionAdsKeys: String {
    case videoAds = "video_ads"
    case videoAd = "video_ad"
    case adURL = "ad_url"
    case offset = "offset"
    
}

class AdvertisementParser {
    
    private var parseData: NSDictionary
    public var parsedAdvertisement: Advertisement = .none
    
    init(parseData: NSDictionary) {
        self.parseData = parseData
    }
    
    // MARK: - Public methods
    
    public func parse() {
        guard let ads = parseData.value(forKey: VideoExtensionAdsKeys.videoAds.rawValue) as? NSDictionary else {
            return
        }
        
        let videoAd = ads.value(forKey: VideoExtensionAdsKeys.videoAd.rawValue)
        if let adList = videoAd as? Array<NSDictionary> {
            parseVastAdList(vastAdList: adList)
        } else if let advertisement = videoAd as? NSDictionary {
            createVmap(advertisement: advertisement)
        }
    }
    
    // MARK: - Private methods
    
    private func parseVastAdList(vastAdList: [NSDictionary]) {
        var parsedAdList: [VastAdvertisement] = []
        for advertisement in vastAdList {
            guard let url = advertisement.value(forKey: VideoExtensionAdsKeys.adURL.rawValue) as? String,
                let offset = advertisement.value(forKey: VideoExtensionAdsKeys.offset.rawValue) as? String,
                let vast = createVast(withUrl: url, andOffset: offset) else {
                continue
            }
            
            parsedAdList.append(vast)
        }
        
        parsedAdvertisement = .vast(parsedAdList)
    }
    
    private func createVast(withUrl url: String,
                            andOffset offset: String) -> VastAdvertisement? {
        if offset == "pre" {
            return .preRoll(url)
        } else if offset == "post" {
            return .postRoll(url)
        } else if let timeline = Int(offset) {
            return .timeline(url, timeline)
        } else {
            return nil
        }
    }
    
    private func createVmap(advertisement: NSDictionary) {
        guard let url = advertisement.value(forKey: VideoExtensionAdsKeys.adURL.rawValue) as? String else {
            return
        }
        
        parsedAdvertisement = .vmap(url)
    }
}

