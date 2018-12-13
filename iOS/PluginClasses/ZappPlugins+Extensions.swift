import ZappPlugins

extension ZPPlayable {
    func toString() -> String {
        return """
        Name: \(String(describing: playableName()))
        Description: \(String(describing: playableDescription()))
        VideoURLPath: \(String(describing: contentVideoURLPath()))
        isLive: \(isLive())
        isFree: \(isFree())
        identifier: \(String(describing: identifier)))
        extensions: \(String(describing: extensionsDictionary))
        analytics: \(String(describing: analyticsParams()))
        """
    }
    
    // MARK: - Analytics
    
    var event: AnalyticsEvent {
        let isLiveItem = extensionsDictionary
            .flatMap { $0["is_live"] }
            .flatMap { $0 as? Bool }
            ?? false
        
        return isLiveItem ? .live : .vod
    }
    
    var additionalAnalyticsParams: [AnyHashable: Any] {
        let isFreeItem = extensionsDictionary
            .flatMap { $0["free"] }
            .flatMap { $0 as? Bool }
            ?? true
        
        return [
            AnalyticsKeys.isFree.rawValue: isFreeItem ? "Free" : "Paid"
        ]
    }
}

extension ZPPlayerConfiguration {
    func toString() -> String {
        return """
        Start time: \(startTime)
        End time: \(endTime)
        Animated: \(animated)
        Should mute: \(playerShouldStartMuted)
        Custom config: \(String(describing: customConfiguration))
        """
    }
}
