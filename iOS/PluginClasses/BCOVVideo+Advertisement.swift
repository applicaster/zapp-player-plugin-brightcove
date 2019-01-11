//
//  BCOVVideo+Advertisement.swift
//  AFNetworking
//
//  Created by Roman Karpievich on 1/10/19.
//

import Foundation
import BrightcovePlayerSDK
import BrightcoveIMA

extension BCOVVideo {
    
    func updateVideo(withAds advertisement: Advertisement) -> BCOVVideo {
        return update { (mutableVideo) in
            switch advertisement {
            case .vmap(let vmapURL):
                mutableVideo?.setVMAPAdvertisement(adURL: vmapURL)
            case .vast(let vastAds):
                mutableVideo?.setVASTAdvertisement(vastAdList: vastAds)
                break
            case .none:
                break
            }
        }
    }
}

private extension BCOVMutableVideo {
    func setVMAPAdvertisement(adURL: String) {
        self.properties[kBCOVIMAAdTag] = adURL
    }
    
    func setVASTAdvertisement(vastAdList: [VastAdvertisement]) {
        var cuePoints: [BCOVCuePoint] = []
        for vastAd in vastAdList {
            var cuePoint: BCOVCuePoint
            switch vastAd {
            case .preRoll(let adURL):
                let properties = [kBCOVIMAAdTag: adURL] as [AnyHashable: Any]
                cuePoint = BCOVCuePoint.beforeCuePointOfType(kBCOVIMACuePointTypeAd, properties: properties)
                break
            case .postRoll(let adURL):
                let properties = [kBCOVIMAAdTag: adURL] as [AnyHashable: Any]
                cuePoint = BCOVCuePoint.afterCuePointOfType(kBCOVIMACuePointTypeAd, properties: properties)
                break
            case .timeline(let adURL, let timeline):
                let properties = [kBCOVIMAAdTag: adURL] as [AnyHashable: Any]
                let time: TimeInterval = Double(timeline)
                cuePoint = BCOVCuePoint.init(type: kBCOVIMACuePointTypeAd,
                                             positionInSeconds: time,
                                             properties: properties)
                break
            }
            
            cuePoints.append(cuePoint)
        }
        self.cuePoints = BCOVCuePointCollection(array: cuePoints)
    }
}
