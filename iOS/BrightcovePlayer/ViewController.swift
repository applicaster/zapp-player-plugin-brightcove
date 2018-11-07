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
        let item1: APURLPlayable = APURLPlayable(streamURL: "http://house-fastly-signed-us-east-1-prod.brightcovecdn.com/media/v1/pmp4/static/clear/5675788000001/cb1034f7-e3cd-4fe5-87e1-56d55da9d387/high.mp4?fastly_token=NWJlNjAxY2ZfMmZjYWY0MDFjY2ZhNjhiOThlYTExMjMyZDY0YTViYTQ1NWZlZDFlYTUyMTExMTdkMGQ5MWMyMTc0N2Y2NzU1Y18vL2hvdXNlLWZhc3RseS1zaWduZWQtdXMtZWFzdC0xLXByb2QuYnJpZ2h0Y292ZWNkbi5jb20vbWVkaWEvdjEvcG1wNC9zdGF0aWMvY2xlYXIvNTY3NTc4ODAwMDAwMS9jYjEwMzRmNy1lM2NkLTRmZTUtODdlMS01NmQ1NWRhOWQzODcvaGlnaC5tcDQ%3D", name: "Test Video", description: "")
       item1.isFree = false
//        let item2: APURLPlayable = APURLPlayable(streamURL: "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8", name: "Test Video", description: "")
//        item2.isLive = true
        
        let pluggablePlayer = ZPPlayerManager.sharedInstance.create(playableItems: [item1], forType: .undefined)
        pluggablePlayer.presentPlayerFullScreen(self.tabBarController!, configuration: nil)
    }
}

