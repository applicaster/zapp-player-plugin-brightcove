//
//  ZPPlayerState+BCOVPlaybackEvents.swift
//  BrightcovePlayerPlugin
//
//  Created by Roman Karpievich on 1/11/19.
//

import Foundation
import ZappPlugins
import BrightcovePlayerSDK

extension ZPPlayerState {
    init?(event: BCOVPlaybackSessionLifecycleEvent) {
        switch event.eventType {
            
        case kBCOVPlaybackSessionLifecycleEventPlaybackStalled,
             kBCOVPlaybackSessionLifecycleEventResumeFail,
             kBCOVPlaybackSessionLifecycleEventFail,
             kBCOVPlaybackSessionLifecycleEventFailedToPlayToEndTime:
            self = .interruption
            
        case kBCOVPlaybackSessionLifecycleEventPause:
            self = .paused
            
        case kBCOVPlaybackSessionLifecycleEventPlaybackRecovered,
             kBCOVPlaybackSessionLifecycleEventPlay:
            self = .playing
            
        case kBCOVPlaybackSessionLifecycleEventEnd:
            self = .stopped
            
        case kBCOVPlaybackSessionLifecycleEventPlaybackBufferEmpty,
             kBCOVPlaybackSessionLifecycleEventResumeBegin,
             kBCOVPlaybackSessionLifecycleEventResumeComplete,
             kBCOVPlaybackSessionLifecycleEventReady,
             kBCOVPlaybackSessionLifecycleEventPlaybackLikelyToKeepUp:
            fallthrough
            
        default:
            return nil
        }
    }
}
