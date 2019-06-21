//
//  ZPPlayable+BCOVVideo.swift
//  BrightcovePlayerPlugin
//
//  Created by Roman Karpievich on 1/9/19.
//  Copyright © 2019 Alex Faizullov. All rights reserved.
//

import Foundation
import BrightcovePlayerSDK
import ZappPlugins

private enum VideoTypes: String {
    case hls = "m3u8"
    case mp4 = "mp4"
}

extension ZPPlayable {
    var bcovVideo: BCOVVideo {
        get {
            let delivery: String = isHLS() ? kBCOVSourceDeliveryHLS : kBCOVSourceDeliveryMP4
            var video: BCOVVideo = BCOVVideo(url: URL(string: contentVideoURLPath()),
                                             deliveryMethod: delivery)
            let extensionsDictionary = self.extensionsDictionary ?? [:]
            let parser = AdvertisementParser(parseData: extensionsDictionary)
            parser.parse()
            
            let captionsParser = CaptionsParser(parseData: extensionsDictionary)
            captionsParser.parse()
            
            video = video
                .updateVideo(with: parser.parsedAdvertisement)
                .updateVideo(with: captionsParser.parsedCaptions)
            
            return video
        }
    }
    
    var advertisementType: Advertisement {
        let extensionsDictionary = self.extensionsDictionary ?? [:]
        let parser = AdvertisementParser(parseData: extensionsDictionary)
        parser.parse()
        return parser.parsedAdvertisement
    }
    
    private func isHLS() -> Bool {
        guard let videoURL = URL(string: contentVideoURLPath()) else {
            assert(false)
            return false
        }
        
        return videoURL.pathExtension == VideoTypes.hls.rawValue
    }
}
