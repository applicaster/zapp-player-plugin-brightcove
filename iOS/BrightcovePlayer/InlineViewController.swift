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
        let item: APURLPlayable = APURLPlayable(streamURL: "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8", name: "Test Video", description: "")
        item.identifier = "123235245"
        item.extensionsDictionary = ["duration" : 12345]
        item.isFree = false
        item.isLive = true
        
        let pluggablePlayer = ZPPlayerManager.sharedInstance.create(playableItem: item)
        pluggablePlayer.pluggablePlayerAddInline(self, container: VideoContainerView)
        pluggablePlayer.pluggablePlayerPlay(nil)
    }
}
