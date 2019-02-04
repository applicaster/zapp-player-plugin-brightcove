//
//  InlineViewController.swift
//  BrightcovePlayer
//
//  Created by Alex Faizullov on 10/18/18.
//  Copyright © 2018 Alex Faizullov. All rights reserved.
//

import Foundation
import ZappPlugins
import ApplicasterSDK

class InlineViewController: UIViewController {
    
    @IBOutlet weak var VideoContainerView: UIView!
    var zappPlayer: ZPPlayerProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        startPlayVideo()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Getting the current player instance and stopping the video player when our view is going to disappear.
        ZPPlayerManager.sharedInstance.lastActiveInstance?.pluggablePlayerStop()
    }
    
    func startPlayVideo() {
        let item = createVASTVideo()
        
        zappPlayer = ZPPlayerManager.sharedInstance.create(playableItem: item)
        zappPlayer?.pluggablePlayerAddInline(self, container: VideoContainerView)
        zappPlayer?.pluggablePlayerPlay(nil)
    }
    
    private func createVASTVideo() -> ZPPlayable {
        let item: APURLPlayable = APURLPlayable(streamURL: "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8", name: "Test Video", description: "")
        item.isFree = false
        item.identifier = "123235245"
        
        item.extensionsDictionary = ["duration" : 12345]
        item.isFree = false
        item.isLive = false
        
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
        let extensionsDictionary = ["free": "true",
                                    "video_ads": ads] as [String : Any]
        item.extensionsDictionary = extensionsDictionary
        
        return item
    }
    
    private func createVMAPVideo() -> ZPPlayable {
        let item: APURLPlayable = APURLPlayable(streamURL: "http://199.203.217.171/xml_parsers/genre-videos/genre-videos-data/videos/comedy.mp4", name: "Test Video", description: "")
        item.isFree = false
        item.identifier = "123235245"
        
        item.extensionsDictionary = ["duration" : 12345]
        item.isFree = false
        item.isLive = false
        
        let vmapUrl = "https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/124319096/external/ad_rule_samples&ciu_szs=300x250&ad_rule=1&impl=s&gdfp_req=1&env=vp&output=vmap&unviewed_position_start=1&cust_params=deployment%3Ddevsite%26sample_ar%3Dpremidpostpod&cmsid=496&vid=short_onecue&correlator="
        
        let extensionsDictionary = ["free": "true",
                                    "video_ads": vmapUrl] as [String : Any]
        item.extensionsDictionary = extensionsDictionary
        
        return item
    }
}
