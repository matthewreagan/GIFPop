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
    @IBOutlet weak var aboutGIFPop: AboutGIFPop!
    
    func applicationDidFinishLaunching(_ notification: Notification)
    {
        let hasShownAboutWindowForFirstLaunchDefaultsKey =
            "GIFPopHasShownAboutWindowForFirstLaunch"
        
        let hasShownAbout = UserDefaults.standard.bool(forKey: hasShownAboutWindowForFirstLaunchDefaultsKey)
        
        if (!hasShownAbout)
        {
            aboutGIFPop.helpButtonClicked(self)
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
    
    func application(_ sender: NSApplication, openFile filename: String) -> Bool
    {
        var utiType : String
        
        do
        {
            utiType = try NSWorkspace.shared().type(ofFile: filename)
        }
        catch
        {
            return false
        }
        
        if (utiType == (kUTTypeGIF as String))
        {
            resizer.loadGIFAtPath(pathToGIF: filename)
            
            return true
        }

        return false
    }
    
    func windowWillClose(_ notification: Notification)
    {
        NSApp.terminate(nil)
    }
}

