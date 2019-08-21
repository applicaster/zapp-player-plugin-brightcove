//
//  VideoItem.swift
//  BrightcovePlayerTVOS
//
//  Created by Egor Brel on 8/15/19.
//

import Foundation
import React
import BrightcovePlayerSDK

private enum VideoTypes: String {
    case hls = "m3u8"
    case mp4 = "mp4"
}

public struct ReactPropsKey {
    static let url = "uri"
}

struct VideoItem {
    let urlString: String
    let delivery: String
    
    init(source: NSDictionary) {
        urlString = source[ReactPropsKey.url] as? String ?? ""
        delivery = VideoItem.isHLS(self.urlString) ? kBCOVSourceDeliveryHLS : kBCOVSourceDeliveryMP4
    }
    
    private static func isHLS(_ path: String) -> Bool {
        guard let videoURL = URL(string: path) else {
            assert(false)
            return false
        }
        
        return videoURL.pathExtension == VideoTypes.hls.rawValue
    }
}

