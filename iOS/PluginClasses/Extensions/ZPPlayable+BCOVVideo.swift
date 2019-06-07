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

extension ZPPlayable {
    var bcovVideo: BCOVVideo {
        get {
            let delivery: String = isLive() ? kBCOVSourceDeliveryHLS : kBCOVSourceDeliveryMP4
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
}
