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
        return isLive() ? .live : .vod
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
