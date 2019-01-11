//
//  ViewController.swift
//  BrightcovePlayer
//
//  Created by Alex Faizullov on 10/18/18.
//  Copyright © 2018 Alex Faizullov. All rights reserved.
//

import UIKit
import ZappPlugins
import ApplicasterSDK
import BrightcovePlayerPlugin

class ViewController: UIViewController {

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
        let item: APURLPlayable = APURLPlayable(streamURL: "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8", name: "Test Video", description: "")
        item.isFree = false
        item.identifier = "123235245"
        
        item.extensionsDictionary = ["duration" : 12345]
        item.isFree = false
        item.isLive = false
        
        // VAST
        //        let firstAd = ["ad_url": "https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/124319096/external/single_ad_samples&ciu_szs=300x250&impl=s&gdfp_req=1&env=vp&output=vast&unviewed_position_start=1&cust_params=deployment%3Ddevsite%26sample_ct%3Dlinear&correlator=",
        //                        "offset": "pre"]
        //        let secondAd = ["ad_url": "https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/124319096/external/single_ad_samples&ciu_szs=300x250&impl=s&gdfp_req=1&env=vp&output=vast&unviewed_position_start=1&cust_params=deployment%3Ddevsite%26sample_ct%3Dredirectlinear&correlator=",
        //                         "offset": "post"]
        //        let thirdAd = ["ad_url": "https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/124319096/external/single_ad_samples&ciu_szs=300x250&impl=s&gdfp_req=1&env=vp&output=vast&unviewed_position_start=1&cust_params=deployment%3Ddevsite%26sample_ct%3Dskippablelinear&correlator=",
        //                        "offset": "3"]
        //        let fourthAd = ["ad_url": "https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/124319096/external/single_ad_samples&ciu_szs=300x250&impl=s&gdfp_req=1&env=vp&output=vast&unviewed_position_start=1&cust_params=deployment%3Ddevsite%26sample_ct%3Dskippablelinear&correlator=",
        //                         "offset": "90"]
        //        let ads = [firstAd, secondAd, thirdAd, fourthAd]
        
        // VMAP
        let vmapUrl = "https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/124319096/external/ad_rule_samples&ciu_szs=300x250&ad_rule=1&impl=s&gdfp_req=1&env=vp&output=vmap&unviewed_position_start=1&cust_params=deployment%3Ddevsite%26sample_ar%3Dpremidpostpod&cmsid=496&vid=short_onecue&correlator="
        
        let ads = ["ad_url": vmapUrl];
        
        let advDictionary = ["video_ad": ads]
        let extensionsDictionary = ["free": "true",
                                    "video_ads": advDictionary] as [String : Any]
        item.extensionsDictionary = extensionsDictionary
        
        let pluggablePlayer = ZPPlayerManager.sharedInstance.create(playableItems: [item], forType: .undefined)
        pluggablePlayer.presentPlayerFullScreen(self.tabBarController!, configuration: nil)
    }
}

