//
//  AppDelegate.swift
//  GIFPop
//
//  Created by Matt Reagan on 10/9/16.
//  Copyright © 2016 Matt Reagan. All rights reserved.
//

import Cocoa

@NSApplicationMain

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate
{
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var resizer: Resizer!
    
    func applicationDidFinishLaunching(_ notification: Notification)
    {
        let hasShownAboutWindowForFirstLaunchDefaultsKey =
            "GIFPopHasShownAboutWindowForFirstLaunch"
        
        let hasShownAbout = UserDefaults.standard.bool(forKey: hasShownAboutWindowForFirstLaunchDefaultsKey)
        
        if (!hasShownAbout)
        {
            resizer.helpButtonClicked(self)
            UserDefaults.standard.set(true, forKey: hasShownAboutWindowForFirstLaunchDefaultsKey)
        }
        
        window.delegate = self
    }

    func applicationWillTerminate(_ aNotification: Notification)
    {
        /*  Clean up our copied GIF (in /tmp) if we can */
        
        if let gifPath = resizer.inputGIFPath
        {
            try? FileManager.default.removeItem(atPath: gifPath)
        }
    }
    
    func windowWillClose(_ notification: Notification)
    {
        NSApp.terminate(nil)
    }
}

