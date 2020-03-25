import Foundation
import ZappPlugins

protocol AnalyticsAdapterProtocol {
    var screenMode: PlayerScreenMode {get set}
    
    func track(event: AnalyticsEvent, withParameters parameters: [AnyHashable: Any], timed: Bool)
    func complete(item: ZPPlayable, progress: Progress)
    func complete(event: AnalyticsEvent, withParameters parameters: [AnyHashable: Any])
}

enum AnalyticsEvent: String {
    case vod = "Play VOD Item"
    case live = "Play Live Stream"
    case advertisement = "Watch Video Advertisement"
    case advertisementError = "Video Ad Error"
    case playbackError = "Video Play Error"
    case pause = "Pause"
    case seek = "Seek"
    case rewind = "Tap Rewind"
    case playerViewSwitch = "Switch Player View"
    case tapCaptions = "Tap Closed Captions"
}

enum AnalyticsKeys: String {
    case view = "View"
    case completed = "Completed"
    case isFree = "Free or Paid Video"
    case itemID = "Item ID"
    case itemName = "Item Name"
    case itemDuration = "Item Duration"
    case timecode = "Timecode"
    case videoType = "Video Type"
    case timecodeFrom = "Timecode From"
    case timecodeTo = "Timecode To"
    case seekDirection = "Seek Direction"
    case durationInVideo = "Duration in Video"
    case originalView = "Original View"
    case newView = "New View"
    case switchInstance = "Switch Instance"
    case captionsPreviousState = "Previous State"
}

extension PlayerScreenMode {
    var analyticsMode: String {
        switch self {
        case .fullscreen:
            return "Full Screen Player"
        case .inline:
            return "Inline Player"
        }
    }
}

class MorpheusAnalyticsAdapter: AnalyticsAdapterProtocol {
    
    typealias Props = [String: Any]
    
    var screenMode = PlayerScreenMode.fullscreen
    
    // MARK: - AnalyticsAdapterProtocol methods
    
    func track(event: AnalyticsEvent, withParameters parameters: [AnyHashable: Any], timed: Bool) {
        guard var params = parameters as? [String: Any] else {
            return
        }
        
        params = params.merge(viewParams(for: screenMode))
        
        ZAAppConnector.sharedInstance().analyticsDelegate?.trackEvent(name: event.rawValue,
                                                                     parameters: params,
                                                                     timed: timed)
    }
    
    func complete(item: ZPPlayable, progress: Progress) {
        let params = item.additionalAnalyticsParams
            .merge(completedParams(for: item, state: progress))
        let event = item.event.rawValue
        
        ZAAppConnector.sharedInstance().analyticsDelegate?.endTimedEvent(event,
                                                                         parameters: params)
    }
    
    func complete(event: AnalyticsEvent, withParameters parameters: [AnyHashable: Any]) {
        guard let params = parameters as? [String: Any] else {
            return
            
        }
        ZAAppConnector.sharedInstance().analyticsDelegate?.endTimedEvent(event.rawValue,
                                                                         parameters: params)
    }
    
    // MARK: - Private methods
    
    private func viewParams(for mode: PlayerScreenMode) -> Props {
        return [AnalyticsKeys.view.rawValue: mode.analyticsMode]
    }
    
    private func completedParams(for item: ZPPlayable, state: Progress) -> Props {
        guard !item.isLive() else { return [:] }
        return [AnalyticsKeys.completed.rawValue : state.isCompleted ? "Yes" : "No"]
    }
}
