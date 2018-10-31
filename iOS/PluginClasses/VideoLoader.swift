import Foundation
import ApplicasterSDK
import BrightcovePlayerSDK

enum Result {
    case success([BCOVVideo])
    case failure(Error)
}

protocol VideoLoader {
    func load(items: [ZPPlayable], completion: (Result) -> Void)
    func find(video: BCOVVideo, in items: [ZPPlayable]) -> ZPPlayable?
}

class StaticURLLoader: VideoLoader {
    func load(items: [ZPPlayable], completion: (Result) -> Void) {
        
        let videos: [BCOVVideo] = items.map { item in
            let delivery: String = item.isLive() ? kBCOVSourceDeliveryHLS : kBCOVSourceDeliveryMP4
            let video: BCOVVideo = BCOVVideo(url: URL(string: item.contentVideoURLPath()), deliveryMethod: delivery)
            return video
        }
        
        completion(.success(videos))
    }
    
    func find(video: BCOVVideo, in items: [ZPPlayable]) -> ZPPlayable? {
        guard let source = video.sources.first as? BCOVSource else { return nil }
        return items.first { $0.contentVideoURLPath() == source.url.absoluteString }
    }
}
