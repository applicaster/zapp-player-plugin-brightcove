//
//  BCOVVideo+Captions.swift
//  BrightcovePlayerPlugin
//
//  Created by Roman Karpievich on 6/7/19.
//

import Foundation
import BrightcovePlayerSDK

extension BCOVVideo {
    
    func updateVideo(with captions: [Captions]) -> BCOVVideo {
        return update({ (mutableVideo) in
            guard var properties = mutableVideo?.properties else {
                return
            }
            
            let currentTextTracks = properties[kBCOVSSVideoPropertiesKeyTextTracks] as? [[String: Any]] ?? [[:]]
            let duration = self.videoDuration()
            
            let textTracks = captions.map({ $0.bcovCaptions(with: duration)})
            let combinedTextTracks = currentTextTracks + textTracks
            mutableVideo?.properties[kBCOVSSVideoPropertiesKeyTextTracks] = combinedTextTracks
        })
    }
    
    func updateCaptions(with duration: TimeInterval) -> BCOVVideo {
        return update({ (mutableVideo) in
            guard let properties = mutableVideo?.properties,
                var textTracks = properties[kBCOVSSVideoPropertiesKeyTextTracks] as? [[String: Any]] else {
                return
            }
            
            textTracks = textTracks.map({ (track) -> [String: Any] in
                var copy = track
                copy[kBCOVSSTextTracksKeyDuration] = NSNumber(value: duration)
                return copy
            })
            
            mutableVideo?.properties[kBCOVSSVideoPropertiesKeyTextTracks] = textTracks
        })
    }
    
    private func videoDuration() -> TimeInterval {
        var duration = 0.0
        
        if let source = self.sources.first as? BCOVSource,
            let url = source.url {
            let asset = AVAsset(url: url)
            duration = asset.duration.seconds
        }
        
        return duration
    }
}

private extension Captions {
    func bcovCaptions(with duration: TimeInterval) -> [String: Any] {
        let kind: String
        switch self.kind {
        case .captions:
            kind = kBCOVSSTextTracksKindCaptions
        case .subtitles:
            kind = kBCOVSSTextTracksKindSubtitles
        }
        
        let bcovCaptions: [String: Any] = [
            kBCOVSSTextTracksKeyKind: kind,
            kBCOVSSTextTracksKeySourceLanguage: self.languageCode,
            kBCOVSSTextTracksKeyLabel: self.label,
            kBCOVSSTextTracksKeySource: self.source,
            kBCOVSSTextTracksKeyDuration: NSNumber(value: duration),
            kBCOVSSTextTracksKeySourceType: kBCOVSSTextTracksKeySourceTypeWebVTTURL,
            kBCOVSSTextTracksKeyMIMEType: self.type
        ]
        
        return bcovCaptions
    }
}
