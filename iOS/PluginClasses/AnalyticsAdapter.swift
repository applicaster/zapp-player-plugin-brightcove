import Foundation
import ZappPlugins
import ApplicasterSDK

protocol AnalyticsAdapter {
    func track(item: ZPPlayable, mode: PlayerScreenMode)
    func complete(item: ZPPlayable, mode: PlayerScreenMode, progress: Progress)
}

enum AnalyticsEvent: String {
    case vod = "Play VOD Item"
    case live = "Play Channel"
}

enum AnalyticsKeys: String {

    case view = "View"
    case completed = "Completed"
    
    // TODO: clarify if we need this
    case duration = "Item Duration"
    case type = "Video Type"
    case identifier = "Item ID"
    case itemName = "Item Name"
    case isFree = "Free or Paid Video"
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

class MorpheusAnalyticsAdapter: AnalyticsAdapter {
    
    typealias Props = [AnyHashable: Any]
    
    func track(item: ZPPlayable, mode: PlayerScreenMode) {
        let params = basicParams(for: item, mode: mode)
        let event = item.event.rawValue
        
        APLoggerDebug("Analytics: Start event \(event) with params \(params)")
        
        APAnalyticsManager.trackEvent(event, withParameters: params, timed: true)
    }
    
    func complete(item: ZPPlayable, mode: PlayerScreenMode, progress: Progress) {
        let params = basicParams(for: item, mode: mode)
            .merge(completedParams(for: item, state: progress))
        let event = item.event.rawValue
        
        APLoggerDebug("Analytics: Complete event \(event) with params \(params)")
        
        APAnalyticsManager.endTimedEvent(event, withParameters: params)
    }
    
    private func basicParams(for item: ZPPlayable, mode: PlayerScreenMode) -> Props {
        return item.analyticsParams()
            .merge(viewParams(for: mode))
    }
    
    private func viewParams(for mode: PlayerScreenMode) -> Props {
        return [AnalyticsKeys.view.rawValue: mode.analyticsMode]
    }
    
    private func completedParams(for item: ZPPlayable, state: Progress) -> Props {
        guard !item.isLive() else { return [:] }
        
        print(state.duration, state.progress)
        
        return [AnalyticsKeys.completed.rawValue : state.isCompleted ? "Yes" : "No"]
    }
    
    // TODO: check if we need it
    
    private func extendedDurationParams(for item: ZPPlayable) -> Props {
        guard let duration = item.extDuration else { return [:] }
        return [ AnalyticsKeys.duration.rawValue: duration]
    }
}