//
//  AppDelegate.swift
//  GIFPop
//
//  Created by Matt Reagan on 10/9/16.
//  Copyright © 2016 Matt Reagan. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var resizer: Resizer!

    func applicationDidFinishLaunching(_ aNotification: Notification)
    {
        
    }

    func applicationWillTerminate(_ aNotification: Notification)
    {
        /*  Clean up our copied GIF (in /tmp) if we can */
        
        if let gifPath = resizer.inputGIFPath
        {
            try? FileManager.default.removeItem(atPath: gifPath)
        }
    }


}

