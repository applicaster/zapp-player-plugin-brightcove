//
//  ViewController.swift
//  BrightcovePlayer
//
//  Created by Alex Faizullov on 10/18/18.
//  Copyright © 2018 Alex Faizullov. All rights reserved.
//

import UIKit
import ZappPlugins
import BrightcovePlayerPlugin

class ViewController: UIViewController {
    
    var zappPlayer: ZPPlayerProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }

    @IBAction func buttonPlay_clicked() {
        self.presentPlayer()
    }
    
    func presentPlayer() {
        let vastItem = createVASTVideo()
        let vmapItem = createVMAPVideo()
        let videoItems = [vastItem]
        
        zappPlayer = ZPPlayerManager.sharedInstance.create(playableItems: videoItems, forType: .undefined)
        zappPlayer?.presentPlayerFullScreen(self.tabBarController!, configuration: nil)
    }
    
    private func createVASTVideo() -> ZPPlayable {
        let item = Playable()
//        item.videoURL = "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8"
//        item.videoURL = "http://besttv61.aoslive.it.best-tv.com/reshet/applicaster/index.m3u8"
        item.videoURL = "http://184.72.239.149/vod/smil:BigBuckBunny.smil/playlist.m3u8"
        item.name = "Test Video"
        item.free = false
        item.identifier = "123235245"
        item.extensionsDictionary = ["duration" : 12345]
        item.live = false
        
        // VAST
        let firstAd = ["ad_url": "https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/124319096/external/single_ad_samples&ciu_szs=300x250&impl=s&gdfp_req=1&env=vp&output=vast&unviewed_position_start=1&cust_params=deployment%3Ddevsite%26sample_ct%3Dlinear&correlator=",
                       "offset": "preroll"]
        let secondAd = ["ad_url": "https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/124319096/external/single_ad_samples&ciu_szs=300x250&impl=s&gdfp_req=1&env=vp&output=vast&unviewed_position_start=1&cust_params=deployment%3Ddevsite%26sample_ct%3Dredirectlinear&correlator=",
                        "offset": "postroll"]
        let thirdAd = ["ad_url": "https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/124319096/external/single_ad_samples&ciu_szs=300x250&impl=s&gdfp_req=1&env=vp&output=vast&unviewed_position_start=1&cust_params=deployment%3Ddevsite%26sample_ct%3Dskippablelinear&correlator=",
                       "offset": "10"]
        let fourthAd = ["ad_url": "https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/124319096/external/single_ad_samples&ciu_szs=300x250&impl=s&gdfp_req=1&env=vp&output=vast&unviewed_position_start=1&cust_params=deployment%3Ddevsite%26sample_ct%3Dskippablelinear&correlator=",
                        "offset": "90"]
        let ads = [firstAd, secondAd, thirdAd, fourthAd]
        let captions = self.captions()
        let extensionsDictionary: NSDictionary = ["free": "true",
                                                  "video_ads": ads,
                                                  "text_tracks": captions]
        item.extensionsDictionary = extensionsDictionary
        
        return item
    }
    
    private func createVMAPVideo() -> ZPPlayable {
        let item = Playable()
        item.videoURL = "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8"
        item.name = "Test Video"
        item.free = false
        item.identifier = "123235245"
        item.extensionsDictionary = ["duration" : 12345]
        item.live = false
        
        let vmapUrl = "https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/124319096/external/ad_rule_samples&ciu_szs=300x250&ad_rule=1&impl=s&gdfp_req=1&env=vp&output=vmap&unviewed_position_start=1&cust_params=deployment%3Ddevsite%26sample_ar%3Dpremidpostpod&cmsid=496&vid=short_onecue&correlator="
        
        let extensionsDictionary: NSDictionary = ["free": "true",
                                                  "video_ads": vmapUrl]
        item.extensionsDictionary = extensionsDictionary
        
        return item
    }
    
    private func captions() -> [String: Any] {
        let firstTrack = ["label": "English",
                          "type": "text/vtt",
                          "language": "en",
                          "source": "https://www.dropbox.com/s/cl9aowtpzfapmjc/raw_sintel_trailer_en.vtt.flat?dl=1",
                          "kind": "Captions"]
        
        let secondTrack = ["label": "French",
                           "type": "text/vtt",
                           "language": "fr",
                           "source": "https://www.dropbox.com/s/deoud5b59n886d7/raw_sintel_trailer_fr.vtt.flat?dl=1",
                           "kind": "Captions"]
        
        let tracks = [firstTrack, secondTrack]
        
        return ["version": "1.0",
                "tracks": tracks]
    }

}

