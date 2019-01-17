//
//  PlayerAdvertisementAdapter.swift
//  BrightcovePlayerPlugin
//
//  Created by Roman Karpievich on 1/17/19.
//

import Foundation
import ZappPlugins
import GoogleInteractiveMediaAds

protocol PlayerAdvertisementProtocol: AdvertisementEventsDelegate {
    var analytics: AnalyticsAdapterProtocol { get set }
}

class PlayerAdvertisement: PlayerAdvertisementProtocol {
    
    var analytics: AnalyticsAdapterProtocol
    private var adAnalyticParams: [AdvertisementAnalyticKeys: Any] = [:]
    
    init(analytics: AnalyticsAdapterProtocol) {
        self.analytics = analytics
    }
    
    // MARK: - PlayerAdvertisementAdapter methods
    
    func willLoadAds(forAdTagURL adTagURL: String) {
        adAnalyticParams = AdvertisementAnalyticKeys.defaultValuesDict()
        adAnalyticParams[.adUnit] = adTagURL
    }
    
    func eventOccured(_ event: IMAAdEvent,
                      atProgress progress: Progress,
                      forItem item: ZPPlayable) {
        guard let advertisement = event.ad else {
            return
        }
        
        switch event.type {
        case .LOADED:
            adAnalyticParams[.itemName] = item.playableName()
            adAnalyticParams[.skippable] = "\(advertisement.isSkippable)"
            adAnalyticParams[.adBreakDuration] = "\(advertisement.duration)"
            adAnalyticParams[.itemID] = item.identifier
            adAnalyticParams[.videoAdType] = advertisementType(forProgress: progress)
            adAnalyticParams[.contentVideoDuration] = timeString(fromTimeInterval: progress.duration)
            // TODO: Add isFree after resolving depedency issue
            
            let params = AdvertisementAnalyticKeys.toStringDict(from: adAnalyticParams)
            analytics.track(event: .advertisement, withParameters: params)
        case .STARTED:
            adAnalyticParams[.adBreakTime] = adBreakTime(fromProgress: progress)
            adAnalyticParams[.adBreakPercentileTime] = percentileTime(fromProgress: progress)
        case .COMPLETE:
            adAnalyticParams[.adExitMethod] = "Completed"
            if advertisement.isSkippable == true {
                adAnalyticParams[.skipped] = "No"
            }
            let params = AdvertisementAnalyticKeys.toStringDict(from: adAnalyticParams)
            analytics.complete(event: .advertisement, withParameters: params)
        case .CLICKED:
            adAnalyticParams[.clicked] = "Yes"
        case .SKIPPED:
            adAnalyticParams[.adExitMethod] = "Skipped"
            adAnalyticParams[.skipped] = "Yes"
            adAnalyticParams[.timeWhenExited] = timeString(fromTimeInterval: progress.progress)
            
            let params = AdvertisementAnalyticKeys.toStringDict(from: adAnalyticParams)
            analytics.complete(event: .advertisement, withParameters: params)
        default:
            break
        }
    }
    
    func advertisementProgress(progress: Double) {
        adAnalyticParams[.timeWhenExited] = "\(progress)"
    }
    
    func loadError(_ error: IMAAdError) {
        adAnalyticParams[.adExitMethod] = "Ad Server Error"
        adAnalyticParams[.adServerError] = error.message
        
        let params = AdvertisementAnalyticKeys.toStringDict(from: adAnalyticParams)
        analytics.complete(event: .advertisement, withParameters: params)
    }
    
    // MARK: - Private methods
    
    private func advertisementType(forProgress progress: Progress) -> String {
        let currentProgress = progress.progress
        let duration = progress.duration
        if currentProgress.isInfinite == true {
            return "Preroll"
        } else if currentProgress > duration {
            return "Postroll"
        } else {
            return "Midroll"
        }
    }
    
    private func timeString(fromTimeInterval interval: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        
        return formatter.string(from: interval) ?? ""
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
        
        return timeString(fromTimeInterval: timeInterval)
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
