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
    static let src = "src"
    public struct SRC {
        static let url            = "uri"
        static let isNetwork      = "isNetwork"
        static let isAsset        = "isAsset"
        static let type           = "type"
        static let mainVer        = "mainVer"
        static let patchVer       = "patchVer"
        /// Not Supported
        static let requestHeaders = "requestHeaders"
        static let target         = "target"
    }
}

struct VideoItem {
    let urlString: String
    let isNetwork: Bool
    let isAsset: Bool
    let delivery: String
    
    init(source: NSDictionary) {
        urlString = source[ReactPropsKey.SRC.url] as? String ?? ""
        isNetwork = RCTConvert.bool(source[ReactPropsKey.SRC.isNetwork])
        isAsset = RCTConvert.bool(source[ReactPropsKey.SRC.isAsset])
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

