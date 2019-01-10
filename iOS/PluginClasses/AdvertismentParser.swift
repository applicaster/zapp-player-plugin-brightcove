//
//  AdvertismentParser.swift
//  BrightcovePlayerPlugin
//
//  Created by Roman Karpievich on 1/9/19.
//

import Foundation

enum Advertisment {
    case vast([VastAdvertisment])
    case vmap(String)
    case none
}

enum VastAdvertisment {
    case preRoll(String)
    case postRoll(String)
    case timeline(String, Int)
}

class AdvertismentParser {
    
    private var parseData: NSDictionary
    public var parsedAdvertisment: Advertisment = .none
    
    init(parseData: NSDictionary) {
        self.parseData = parseData
    }
    
    public func parse() {
        guard let ads = parseData.value(forKey: VideoExtensionAdsKeys.videoAds.rawValue) as? NSDictionary else {
            return
        }
        
        let videoAd = ads.value(forKey: VideoExtensionAdsKeys.videoAd.rawValue)
        if let adList = videoAd as? Array<NSDictionary> {
            parseVastAdList(vastAdList: adList)
        } else if let advertisment = videoAd as? NSDictionary {
            createVmap(advertisment: advertisment)
        }
    }
    
    // MARK: - Private methods
    
    private func parseVastAdList(vastAdList: [NSDictionary]) {
        var parsedAdList: [VastAdvertisment] = []
        for advertisment in vastAdList {
            guard let url = advertisment.value(forKey: VideoExtensionAdsKeys.adURL.rawValue) as? String,
                let offset = advertisment.value(forKey: VideoExtensionAdsKeys.offset.rawValue) as? String,
                let vast = createVast(withUrl: url, andOffset: offset) else {
                continue
            }
            
            parsedAdList.append(vast)
        }
        
        parsedAdvertisment = .vast(parsedAdList)
    }
    
    private func createVast(withUrl url: String,
                            andOffset offset: String) -> VastAdvertisment? {
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
    
    private func createVmap(advertisment: NSDictionary) {
        guard let url = advertisment.value(forKey: VideoExtensionAdsKeys.adURL.rawValue) as? String else {
            return
        }
        
        parsedAdvertisment = .vmap(url)
    }
}

