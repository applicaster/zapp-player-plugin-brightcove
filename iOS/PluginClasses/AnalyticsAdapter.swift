import Foundation
import ZappPlugins
import ApplicasterSDK

protocol AnalyticsAdapterProtocol {
    func track(item: ZPPlayable, mode: PlayerScreenMode)
    func track(event: AnalyticsEvent, withParameters parameters: [AnyHashable: Any])
    func complete(item: ZPPlayable, mode: PlayerScreenMode, progress: Progress)
    func complete(event: AnalyticsEvent, withParameters parameters: [AnyHashable: Any])
}

enum AnalyticsEvent: String {
    case vod = "Play VOD Item"
    case live = "Play Live Stream"
    case advertisement = "Watch Video Advertisement"
}

enum AnalyticsKeys: String {
    case view = "View"
    case completed = "Completed"
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

class MorpheusAnalyticsAdapter: AnalyticsAdapterProtocol {
    
    typealias Props = [AnyHashable: Any]
    
    // MARK: - AnalyticsAdapterProtocol methods
    
    func track(item: ZPPlayable, mode: PlayerScreenMode) {
        let params = basicParams(for: item, mode: mode)
        let event = item.event.rawValue
        
        APLoggerDebug("Analytics: Start event \(event) with params \(params)")
        
        APAnalyticsManager.trackEvent(event, withParameters: params, timed: true)
    }
    
    func track(event: AnalyticsEvent, withParameters parameters: [AnyHashable: Any]) {
        APAnalyticsManager.trackEvent(event.rawValue, withParameters: parameters)
    }
    
    func complete(item: ZPPlayable, mode: PlayerScreenMode, progress: Progress) {
        let params = basicParams(for: item, mode: mode)
            .merge(completedParams(for: item, state: progress))
        let event = item.event.rawValue
        
        APLoggerDebug("Analytics: Complete event \(event) with params \(params)")
        
        APAnalyticsManager.endTimedEvent(event, withParameters: params)
    }
    
    func complete(event: AnalyticsEvent, withParameters parameters: [AnyHashable: Any]) {
        APAnalyticsManager.endTimedEvent(event.rawValue, withParameters: parameters)
    }
    
    // MARK: - Private methods
    
    private func basicParams(for item: ZPPlayable, mode: PlayerScreenMode) -> Props {
        return item.analyticsParams()
            .merge(item.additionalAnalyticsParams)
            .merge(viewParams(for: mode))
    }
    
    private func viewParams(for mode: PlayerScreenMode) -> Props {
        return [AnalyticsKeys.view.rawValue: mode.analyticsMode]
    }
    
    private func completedParams(for item: ZPPlayable, state: Progress) -> Props {
        guard !item.isLive() else { return [:] }
        return [AnalyticsKeys.completed.rawValue : state.isCompleted ? "Yes" : "No"]
    }
}
