import ZappPlugins

extension ZPPlayable {
    func toString() -> String {
        return """
        Name: \(playableName())
        Description: \(playableDescription())
        VideoURLPath: \(contentVideoURLPath())
        isLive: \(isLive())
        isFree: \(isFree())
        identifier: \(String(describing: identifier)))
        extensions: \(String(describing: extensionsDictionary))
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
