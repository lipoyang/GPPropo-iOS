//
//  ViewController.swift
//  GPPropo
//
//  Created by Bizan Nishimura on 2016/04/19.
//  Copyright (C)2016 Bizan Nishimura. All rights reserved.
//

import UIKit

// BLE status
enum BLEStatus {
    case DISCONNECTED
    case CONNECTING
    case CONNECTED
}

// main view controller
class ViewController: UIViewController, PropoDelegate {
    
    // Bluetooth status
    var btState = BLEStatus.DISCONNECTED
    
    // 4WS Mode
    var mode4ws:Int = 0
    let MODE_FRONT:Int = 0
    let MODE_COMMON:Int = 1
    let MODE_REVERSE:Int = 2
    let MODE_REAR:Int = 3
    
    // Propo view
    var propoView: PropoView?
    
    // on view loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // position of UIViewController.view
        let x:CGFloat = self.view.bounds.origin.x
        let y:CGFloat = self.view.bounds.origin.y
        // size of UIViewController.view
        let width:CGFloat = self.view.bounds.width;
        let height:CGFloat = self.view.bounds.height
        // create a frame fit to UIViewController.view
        let frame:CGRect = CGRect(x: x, y: y, width: width, height: height)
        // create a propo view
        propoView = PropoView(frame: frame)
        propoView!.parent = self
        self.view.addSubview(propoView!)
        
    }
    
    // on view will appear
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // 4WS Mode
        let ud = NSUserDefaults.standardUserDefaults()
        mode4ws = ud.integerForKey("mode4ws")
        
        // on Koshian device connected
        Konashi.shared().connectedHandler = {
            NSLog("connectedHandler")
            self.btState = BLEStatus.CONNECTED;
            self.propoView!.setBtStatus(self.btState);
        }
        // on Koshian device ready
        Konashi.shared().readyHandler = {
            NSLog("readyHandler")
            Konashi.uartMode(KonashiUartMode.Enable, baudrate: KonashiUartBaudrate.Rate38K4)
        }
        // on Koshian device disconnected
        Konashi.shared().disconnectedHandler = {
            NSLog("disconnectedHandler")
            self.btState = BLEStatus.DISCONNECTED;
            self.propoView!.setBtStatus(self.btState);
        }
        // on Koshian connect canceled
        NSNotificationCenter.defaultCenter().addObserver(
            self, selector: #selector(onConnectCanceled(_:)), name: KonashiEventPeripheralSelectorDidSelectNotification, object: nil)
        // on Koshian device not found
        NSNotificationCenter.defaultCenter().addObserver(
            self, selector: #selector(onDeviceNotFound(_:)), name: KonashiEventNoPeripheralsAvailableNotification, object: nil)
    }
    
    // on Koshian connect canceled
    func onConnectCanceled(notification: NSNotification?)
    {
        if  let val = notification?.object {
            let intval = val.intValue
            if  intval == -1 {
                btState = BLEStatus.DISCONNECTED;
                propoView!.setBtStatus(btState);
            }
        }
    }
    
    // on Koshian device not found
    func onDeviceNotFound(notification: NSNotification?)
    {
        btState = BLEStatus.DISCONNECTED;
        propoView!.setBtStatus(btState);
    }
    
    // on memory warning
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // On touch PropoView's Bluetooth Button
    func onTouchBtButton()
    {
        // Connecting
        if(btState == BLEStatus.DISCONNECTED){
        //if(!Konashi.isReady()){
            btState = BLEStatus.CONNECTING;
            propoView!.setBtStatus(btState);
    
            // search Koshian, and open a selection dialog
            Konashi.find()
        }
        // Disconnecting
        else {
            // disconnect Koshian
            Konashi.disconnect();
        }
    }
    
    // On touch PropoView's Setting Button
    func onTouchSetButton()
    {
        // go to SettingActivity
        if(btState == BLEStatus.CONNECTED){
        //if(Konashi.isReady()){
            
            let targetViewController = self.storyboard!.instantiateViewControllerWithIdentifier( "setting" )
            self.presentViewController( targetViewController, animated: true, completion: nil)
        }
    }
    
    // On touch PropoView's FB Stick
    // fb = -1.0 ... +1.0
    func onTouchFbStick(fb: Float)
    {
        if(!Konashi.isConnected()) {return}
    
        // send the Koshian a message.
        var bFB = (Int)(fb * 127);
        if(bFB<0) {bFB += 256}
        let command = String(format: "#D%02X$", bFB )
        NSLog("command;\(command)")
        Konashi.uartWriteString(command)
    }
    
    // On touch PropoView's LR Stick
    // lr = -1.0 ... +1.0
    func onTouchLrStick(lr: Float)
    {
        if(!Konashi.isConnected()) {return}
    
        // send the Koshian a message.
        var bLR = (Int)(lr * 127);
        if(bLR<0) {bLR += 256}
        let command = String(format: "#T%02X%1d$", bLR, mode4ws )
        NSLog("command;\(command)")
        Konashi.uartWriteString(command)
    }
}

