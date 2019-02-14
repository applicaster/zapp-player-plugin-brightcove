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
        guard let advertisementData = parseData.value(forKey: VideoExtensionAdsKeys.videoAds.rawValue) else {
            return
        }
        
        switch advertisementData {
        case let url as String:
            parsedAdvertisement = .vmap(url)
        case let vastAdList as Array<NSDictionary>:
            parseVastAdList(vastAdList: vastAdList)
        default:
            break
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
        if offset == "preroll" {
            return .preRoll(url)
        } else if offset == "postroll" {
            return .postRoll(url)
        } else if let timeline = Double(offset) {
            return .timeline(url, Int(timeline))
        } else {
            return nil
        }
    }
}

