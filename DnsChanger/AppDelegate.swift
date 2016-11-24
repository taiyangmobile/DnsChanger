//
//  AppDelegate.swift
//  DnsChanger
//
//  Created by Peter Young on 18/11/2016.
//  Copyright © 2016 Peter Young. All rights reserved.
//

import Cocoa
import AppleScriptKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        let data = self.getData()
        
        self.initMenu(data: data)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func initMenu(data: [String: [String]]) {
        let menu = NSMenu(title: "DnsChanger")
        
        let itemDefault = NSMenuItem(title: "Default", action: #selector(setDefaultDns), keyEquivalent: "")
        menu.addItem(itemDefault)
        menu.addItem(NSMenuItem.separator())
        
        if let dns = data["dns"] {
            for d  in dns {
                let itemNew = NSMenuItem(title: d, action: #selector(setDnsByMenu), keyEquivalent: "")
                
                menu.addItem(itemNew)
            }
        }
        
        menu.addItem(NSMenuItem.separator())
        let itemQuit = NSMenuItem(title: "Quit", action: #selector(exit), keyEquivalent: "")
        menu.addItem(itemQuit)
        
        statusItem.menu = menu
        statusItem.title = "D"
    }
    
    func getData() -> [String: [String]] {
        let dataFile = NSHomeDirectory().appending("/dnschanger.json")
        
        if let data = try? Data(contentsOf: URL(fileURLWithPath: dataFile)) {
            do {
                let obj = try JSONSerialization.jsonObject(with: data as Data, options: .allowFragments) as! [String: [String]]
                
                return obj
            }
            catch let error as Error {
                print("error:\n \(error)")
            }
        }
        
        return ["dns": ["119.29.29.29"]]
    }
    
    func setDefaultDns(sneder: AnyObject) {
        self.setDns(dns: "empty")
    }
    
    func setDnsByMenu(sender: NSMenuItem) {
        let dns = sender.title
        self.setDns(dns: dns)
    }
    
    func exit(sender: AnyObject) {
        NSApplication.shared().terminate(sender)
    }
    
    private func setDns(dns: String) {
        let shell = "do shell script \"networksetup -setdnsservers Wi-Fi " + dns + "\""
        
        let appleScript = NSAppleScript.init(source: shell)
        appleScript?.executeAndReturnError(nil)
    }
}

