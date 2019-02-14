//
//  IMAErrorWrapper.swift
//  BrightcovePlayerPlugin
//
//  Created by Roman Karpievich on 1/21/19.
//

import Foundation

enum IMAErrorTypes: Int {
    case adUnknownErrorType = 0
    case adLoadingFailed = 1
    case adPlayingFailed = 2
    
    var key: String {
        return "Ad Provider Error Code"
    }
    
    func stringValue() -> String {
        switch self {
        case .adUnknownErrorType:
            return "AdUnknownErrorType"
        case .adLoadingFailed:
            return "AdLoadingFailed"
        case .adPlayingFailed:
            return "AdPlayingFailed"
        }
    }
}

enum IMAErrorCodes: Int {
    case vastMalformedResponse = 100
    case unknownAdResponse = 200
    case vastLoadTimeout = 301
    case vastTooManyRedirects = 302
    case vastInvalidUrl = 303
    case videoPlayError = 400
    case vastMediaLoadTimeout = 402
    case vastLinearAssetMismatch = 403
    case companionAdLoadingFailed = 603
    case unknownError = 900
    case playlistMalformedResponse = 1004
    case failedToRequestAds = 1005
    case requiredListenersNotAdded = 1006
    case vastAssetNotFound = 1007
    case adslotNotVisible = 1008
    case vastEmptyResponse = 1009
    case failedLoadingAd = 1010
    case streamInitializationFailed = 1020
    case invalidArguments = 1101
    case apiError = 1102
    case iosRuntimeTooOld = 1103
    case videoElementUsed = 1201
    case videoElementRequired = 1202
    case contentPlayheadMissing = 1205
    case unknown = -1
    
    var key: String {
        return "ErrorCode"
    }
    
    func stringValue() -> String {
        switch self {
        case .vastMalformedResponse:
            return "VastMalformedResponse"
        case .unknownAdResponse:
            return "UnknownAdResponse"
        case .vastLoadTimeout:
            return "VastLoadTimeout"
        case .vastTooManyRedirects:
            return "VastTooManyRedirects"
        case .vastInvalidUrl:
            return "VastInvalidUrl"
        case .videoPlayError:
            return "VideoPlayError"
        case .vastMediaLoadTimeout:
            return "VastMediaLoadTimeout"
        case .vastLinearAssetMismatch:
            return "VastLinearAssetMismatch"
        case .companionAdLoadingFailed:
            return "CompanionAdLoadingFailed"
        case .unknownError:
            return "UnknownError"
        case .playlistMalformedResponse:
            return "PlaylistMalformedResponse"
        case .failedToRequestAds:
            return "FailedToRequestAds"
        case .requiredListenersNotAdded:
            return "RequiredListenersNotAdded"
        case .vastAssetNotFound:
            return "VastAssetNotFound"
        case .adslotNotVisible:
            return "AdslotNotVisible"
        case .vastEmptyResponse:
            return "VastEmptyResponse"
        case .failedLoadingAd:
            return "FailedLoadingAd"
        case .streamInitializationFailed:
            return "StreamInitializationFailed"
        case .invalidArguments:
            return "InvalidArguments"
        case .apiError:
            return "ApiError"
        case .iosRuntimeTooOld:
            return "iosRuntimeTooOld"
        case .videoElementUsed:
            return "VideoElementUsed"
        case .videoElementRequired:
            return "VideoElementRequired"
        case .contentPlayheadMissing:
            return "ContentPlayheadMissing"
        case .unknown:
            return "Unknown"
        }
    }
}
