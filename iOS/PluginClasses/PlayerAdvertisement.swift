//
//  PlayerAdvertisement.swift
//  BrightcovePlayerPlugin
//
//  Created by Roman Karpievich on 1/17/19.
//

import Foundation
import ZappPlugins
import GoogleInteractiveMediaAds
import BrightcoveIMA

class PlayerAdvertisement: PlayerAdvertisementEventsDelegate {
    
    var analytics: AnalyticsAdapterProtocol
    private var adAnalytic: AdAnalytic?
    
    init(analytics: AnalyticsAdapterProtocol) {
        self.analytics = analytics
    }
    
    // MARK: - PlayerAdvertisementEventsDelegate methods
    
    func willLoadAds(forAdTagURL adTagURL: String,
                     forItem item: ZPPlayable) {
        adAnalytic = AdAnalytic()
        adAnalytic?.adUnit = adTagURL
        adAnalytic?.itemName = item.playableName()
        adAnalytic?.itemID = item.identifier as String? ?? ""
        adAnalytic?.itemPriceType = ItemPriceType(fromBool: item.isFree)
    }
    
    func eventOccured(_ event: BCOVPlaybackSessionLifecycleEvent,
                      duringSession session: BCOVPlaybackSession,
                      forItem item: ZPPlayable) {
        switch event.eventType {
        case kBCOVIMALifecycleEventAdsLoaderFailed,
             kBCOVIMALifecycleEventAdsManagerDidReceiveAdError:
            if let error = event.properties[kBCOVIMALifecycleEventPropertyKeyAdError] as? IMAAdError {
                loadError(error, forItem: item)
            }
        case "kBCOVPlaybackSessionLifecycleEventAdProgress":
            let adProgressKey = "kBCOVPlaybackSessionLifecycleEventPropertiesKeyAdProgress"
            if let currentProgress = event.properties[adProgressKey] as? Double {
                advertisementProgress(progress: currentProgress)
            }
        case kBCOVIMALifecycleEventAdsManagerDidReceiveAdEvent:
            if let adEvent = event.properties["adEvent"] as? IMAAdEvent {
                let duration = session.player.currentItem!.duration.seconds
                let currentTime = session.player.currentTime().seconds
                let progress = Progress(progress: currentTime, duration: duration)
                eventOccured(adEvent, atProgress: progress, forItem: item)
            }
        default:
            break
        }
    }
    
    func eventOccured(_ event: IMAAdEvent,
                      atProgress progress: Progress,
                      forItem item: ZPPlayable) {
        guard let advertisement = event.ad else {
            return
        }
        
        switch event.type {
        case .LOADED:
            adAnalytic?.skippable = advertisement.isSkippable
            adAnalytic?.adBreakDuration = "\(advertisement.duration)"
            adAnalytic?.videoDuration = String.create(fromInterval: progress.duration)
            adAnalytic?.videoAdType = advertisementType(forProgress: progress)
            
            if let params = adAnalytic?.dictionary {
                analytics.track(event: .advertisement,
                                withParameters: params,
                                timed: true)
            }
        case .STARTED:
            adAnalytic?.adBreakTime = adBreakTime(fromProgress: progress)
            adAnalytic?.adBreakPercentileTime = percentileTime(fromProgress: progress)
        case .COMPLETE:
            adAnalytic?.exitMethod = .completed
            
            if advertisement.isSkippable == true {
                adAnalytic?.skipped = .no
            }
            
            if let params = adAnalytic?.dictionary {
                analytics.track(event: .advertisement,
                                withParameters: params,
                                timed: true)
            }
        case .CLICKED:
            adAnalytic?.clicked = true
        case .SKIPPED:
            adAnalytic?.exitMethod = .skipped
            adAnalytic?.skipped = .yes
            adAnalytic?.exitTime = String.create(fromInterval: progress.progress)
            
            if let params = adAnalytic?.dictionary {
                analytics.track(event: .advertisement,
                                withParameters: params,
                                timed: true)
            }
        default:
            break
        }
    }
    
    func advertisementProgress(progress: Double) {
        adAnalytic?.exitTime = "\(progress)"
    }
    
    func loadError(_ error: IMAAdError,
                   forItem item: ZPPlayable) {
        adAnalytic?.exitMethod = .adServerError
        adAnalytic?.adServerError = error.message
        
        if let params = adAnalytic?.dictionary {
            analytics.track(event: .advertisement,
                            withParameters: params,
                            timed: true)
        }
        
        var adError = AdError(from: error, forItem: item)
        adError.screenMode = analytics.screenMode
        adError.isCompleted = (adAnalytic?.videoAdType == .postroll) ? true : false
        adError.itemDuration = adAnalytic?.videoDuration ?? ""
        
        analytics.track(event: .advertisementError,
                        withParameters: adError.dictionary,
                        timed: false)
    }
    
    // MARK: - Private methods
    
    private func advertisementType(forProgress progress: Progress) -> AdTypes {
        let currentProgress = progress.progress
        let duration = progress.duration
        if currentProgress.isInfinite == true {
            return .preroll
        } else if currentProgress > duration {
            return .postroll
        } else {
            return .midroll
        }
    }
    
    private func adBreakTime(fromProgress progress: Progress) -> String {
        let currentProgress = progress.progress
        let duration = progress.duration
        var timeInterval = 0.0
        if currentProgress.isInfinite == true {
            timeInterval = 0
        } else if currentProgress > duration {
            timeInterval = duration
        } else {
            timeInterval = progress.progress
        }
        
        return String.create(fromInterval: timeInterval)
    }
    
    private func percentileTime(fromProgress progress: Progress) -> String {
        let currentProgress = progress.progress
        let duration = progress.duration
        if currentProgress.isInfinite == true {
            return "0"
        } else if currentProgress > duration {
            return "100"
        } else {
            let percentile = (currentProgress / duration).rounded(.down)
            return "\(percentile)"
        }
    }

}
