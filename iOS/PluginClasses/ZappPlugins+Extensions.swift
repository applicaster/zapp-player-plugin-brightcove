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

// MARK: - Analytics

extension ZPPlayable {
    var event: AnalyticsEvent {
        return isLive() ? .live : .vod
    }
    
    var parameters: [AnyHashable: Any] {
        return [
            AnalyticsKeys.identifier.rawValue: identifier ?? NSNull(),
            AnalyticsKeys.itemName.rawValue: playableName(),
            AnalyticsKeys.isFree.rawValue: isFree() ? "Free" : "Paid",
        ]
    }
    
    var extDuration: String? {
        guard let extras = extensionsDictionary else { return nil }
        guard let anyDuration = extras["duration"] else { return nil }
        
        var duration: TimeInterval?
        
        if let integer = anyDuration as? Int {
            duration = TimeInterval(integer)
        } else if let string = anyDuration as? NSString {
            duration = TimeInterval(string.intValue)
        }
        
        return duration.flatMap {
            let formatter = DateComponentsFormatter()
            formatter.unitsStyle = .positional
            formatter.allowedUnits = [.hour, .minute, .second]
            formatter.zeroFormattingBehavior = [.pad]
            return formatter.string(from: $0)
        }
    }
}
