//
//  CaptionsParser.swift
//  BrightcovePlayerPlugin
//
//  Created by Roman Karpievich on 6/6/19.
//

import Foundation
import BrightcovePlayerSDK

struct Captions {
    let label: String
    let kind: CaptionsKind
    let languageCode: String
    let source: String
    let type: String
}

enum CaptionsKind: String {
    case captions = "Captions"
    case subtitles = "Subtitles"
}

enum CaptionsKeys: String {
    case captions = "text_tracks"
    case version = "version"
    case captionsList = "tracks"
    case label = "label"
    case type = "type"
    case language = "language"
    case source = "source"
    case kind = "kind"
}

class CaptionsParser {
    
    private let parseData: NSDictionary
    private(set) var parsedCaptions: [Captions] = []
    
    init(parseData: NSDictionary) {
        self.parseData = parseData
    }
    
    // MARK: - Public methods
    
    public func parse() {
        guard let captionsData = parseData[CaptionsKeys.captions.rawValue] as? [String: Any],
            let captionsList = captionsData[CaptionsKeys.captionsList.rawValue] as? [[String: String]] else {
            return
        }
        
        parsedCaptions = captionsList.compactMap({ (caption) -> Captions? in
            guard let label = caption[CaptionsKeys.label.rawValue],
                let kindString = caption[CaptionsKeys.kind.rawValue],
                let kind = CaptionsKind(rawValue: kindString),
                let language = caption[CaptionsKeys.language.rawValue],
                let source = caption[CaptionsKeys.source.rawValue],
                let type = caption[CaptionsKeys.type.rawValue] else {
                    return nil
            }
            
            return Captions(label: label,
                            kind: kind,
                            languageCode: language,
                            source: source,
                            type: type)
            })
    }
    
}
