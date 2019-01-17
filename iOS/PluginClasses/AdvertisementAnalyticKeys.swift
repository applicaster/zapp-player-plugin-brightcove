//
//  AdvertisementAnalyticKeys.swift
//  BrightcovePlayerPlugin
//
//  Created by Roman Karpievich on 1/17/19.
//

import Foundation

enum AdvertisementAnalyticKeys: String, Hashable {
    case videoAdType = "Video Ad Type"
    case adProvider = "Ad Provider"
    case adUnit = "Ad Unit"
    case skippable = "Skippable"
    case skipped = "Skipped"
    case contentVideoDuration = "Content Video Duration"
    case adBreakTime = "Ad Break Time"
    case adBreakDuration = "Ad Break Duration"
    case midrollInterval = "Midroll Interval"
    case adExitMethod = "Ad Exit Method"
    case timeWhenExited = "Time When Exited"
    case adServerError = "Ad Server Error"
    case clicked = "Clicked"
    case itemName = "Item Name"
    case itemID = "Item ID"
    case freeOrPaid = "Free/Paid"
    case adBreakPercentileTime = "Ad Break Percentile Time"
    case vodType = "VOD Type"
    
    func defaultValue() -> String {
        switch self {
        case .adExitMethod:
            return "Unspecified"
        case .skipped, .adServerError:
            return "N/A"
        case .vodType:
            return "ATOM"
        default:
            return ""
        }
    }
    
    static func defaultValuesDict() -> [AdvertisementAnalyticKeys: Any] {
        // TODO: Replace it using enum's allCases when Swift version will be updated to 4.2
        return [.videoAdType: AdvertisementAnalyticKeys.videoAdType.defaultValue(),
                .adProvider: AdvertisementAnalyticKeys.adProvider.defaultValue(),
                .adUnit: AdvertisementAnalyticKeys.adUnit.defaultValue(),
                .skippable: AdvertisementAnalyticKeys.skippable.defaultValue(),
                .skipped: AdvertisementAnalyticKeys.skipped.defaultValue(),
                .contentVideoDuration: AdvertisementAnalyticKeys.contentVideoDuration.defaultValue(),
                .adBreakTime: AdvertisementAnalyticKeys.adBreakTime.defaultValue(),
                .midrollInterval: AdvertisementAnalyticKeys.midrollInterval.defaultValue(),
                .adBreakDuration: AdvertisementAnalyticKeys.adBreakDuration.defaultValue(),
                .adExitMethod: AdvertisementAnalyticKeys.adExitMethod.defaultValue(),
                .timeWhenExited: AdvertisementAnalyticKeys.timeWhenExited.defaultValue(),
                .adServerError: AdvertisementAnalyticKeys.adServerError.defaultValue(),
                .clicked: AdvertisementAnalyticKeys.clicked.defaultValue(),
                .itemName: AdvertisementAnalyticKeys.itemName.defaultValue(),
                .itemID: AdvertisementAnalyticKeys.itemID.defaultValue(),
                .freeOrPaid: AdvertisementAnalyticKeys.freeOrPaid.defaultValue(),
                .adBreakPercentileTime: AdvertisementAnalyticKeys.adBreakPercentileTime.defaultValue(),
                .vodType: AdvertisementAnalyticKeys.vodType.defaultValue()]
    }
    
    static func toStringDict(from: [AdvertisementAnalyticKeys: Any]) -> [String: Any] {
        var result: [String: Any] = [:]
        for (key, value) in from {
            result.updateValue(value, forKey: key.rawValue)
        }
        
        return result
    }
}
