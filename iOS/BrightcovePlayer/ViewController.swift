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
        let item: ZPPlayable = APURLPlayable(streamURL: "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8", name: "Test Video", description: "")
        let pluggablePlayer = ZPPlayerManager.sharedInstance.create(playableItem: item)
        pluggablePlayer.presentPlayerFullScreen?(self, configuration: nil) {
            pluggablePlayer.pluggablePlayerPlay(nil)
        }
    }
}

