//
//  SettingViewController.swift
//  GPPropo
//
//  Created by Bizan Nishimura on 2016/05/29.
//  Copyright (c)2016 Bizan Nishimura. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController,
        NumericUpDownDelegate, SerialDelegate,
        UIPickerViewDelegate, UIPickerViewDataSource
{
    // Bluetooth status
    var btState = BLEStatus.DISCONNECTED
    
    // serial receiver
    var serialReceiver:SerialReceiver?
    
    // 4WS Mode
    var mode4ws:Int = 0
    let MODE_FRONT:Int = 0
    let MODE_COMMON:Int = 1
    let MODE_REVERSE:Int = 2
    let MODE_REAR:Int = 3
    let MODE_4WS_LIST = ["FRONT","REAR","NORMAL","REVERSE"]
    
    // UI views
    @IBOutlet weak var textVbat: UILabel!
    @IBOutlet weak var switchRev0: UISwitch!
    @IBOutlet weak var switchRev1: UISwitch!
    @IBOutlet weak var switchRev2: UISwitch!
    @IBOutlet weak var viewTrim0: NumericUpDownView!
    @IBOutlet weak var viewTrim1: NumericUpDownView!
    @IBOutlet weak var viewTrim2: NumericUpDownView!
    @IBOutlet weak var viewGain0: NumericUpDownView!
    @IBOutlet weak var viewGain1: NumericUpDownView!
    @IBOutlet weak var viewGain2: NumericUpDownView!
    @IBOutlet weak var picker4WS: UIPickerView!
    
    // on loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UI views
        viewTrim0!.parent = self
        viewTrim1!.parent = self
        viewTrim2!.parent = self
        viewGain0!.parent = self
        viewGain1!.parent = self
        viewGain2!.parent = self
        viewTrim0!.setFormat("%+4d")
        viewTrim1!.setFormat("%+4d")
        viewTrim1!.setFormat("%+4d")
        viewGain0!.setFormat("%4d")
        viewGain1!.setFormat("%4d")
        viewGain2!.setFormat("%4d")
        viewTrim0!.setMaxMin(max:127, min:-127)
        viewTrim1!.setMaxMin(max:127, min:-127)
        viewTrim2!.setMaxMin(max:127, min:-127)
        viewGain0!.setMaxMin(max:255, min:0)
        viewGain1!.setMaxMin(max:255, min:0)
        viewGain2!.setMaxMin(max:255, min:0)
        
        // 4WS Mode
        picker4WS.dataSource = self
        picker4WS.delegate = self
        let ud = NSUserDefaults.standardUserDefaults()
        let mode4ws = ud.integerForKey("mode4ws")
        switch(mode4ws)
        {
        case MODE_FRONT:
            picker4WS.selectRow(0, inComponent:0, animated:false);
            break;
        case MODE_REAR:
            picker4WS.selectRow(1, inComponent:0, animated:false);
            break;
        case MODE_COMMON:
            picker4WS.selectRow(2, inComponent:0, animated:false);
            break;
        case MODE_REVERSE:
            picker4WS.selectRow(3, inComponent:0, animated:false);
            break;
        default:
            picker4WS.selectRow(0, inComponent:0, animated:false);
            break;
        }
        
        // serial receiver
        serialReceiver = SerialReceiver();
        serialReceiver!.setListener(self);
    }
    
    // on view will appear
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // on Koshian device disconnected
        Konashi.shared().disconnectedHandler = {
            NSLog("disconnectedHandler")
            self.btState = BLEStatus.DISCONNECTED;
        }
        // on Koshian receive data
        Konashi.shared().uartRxCompleteHandler = {
            (nsData:NSData!) -> Void in
            
            var bData = Array<UInt8>(count: nsData.length, repeatedValue: 0)
            nsData.getBytes(&bData, length: nsData.length)
            
            self.serialReceiver!.put(bData);
        }
        
        btState = Konashi.isReady() ? BLEStatus.CONNECTED : BLEStatus.DISCONNECTED;
        
        sendCommand("#AL$");
    }
    // on view will disappear
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        
    }

    // on tap [SAVE]
    @IBAction func onTapSave(sender: AnyObject) {
        let command:String = "#AS$";
        sendCommand(command);
    }
    // on tap [RELOAD]
    @IBAction func onTapReload(sender: AnyObject) {
        let command:String = "#AL$";
        sendCommand(command);
    }
    // on tap [BACK]
    @IBAction func onTapBack(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion:nil)
    }
    
    // on change REV CH0
    @IBAction func onChangeRev0(sender: UISwitch) {
        var command:String
        command = sender.on ? "#AP-0$" : "#AP+0$";
        sendCommand(command);
        command = "#S000$";
        sendCommand(command);
    }
    // on change REV CH1
    @IBAction func onChangeRev1(sender: UISwitch) {
        var command:String
        command = sender.on ? "#AP-1$" : "#AP+1$";
        sendCommand(command);
        command = "#S001$";
        sendCommand(command);
    }
    // on change REV CH2
    @IBAction func onChangeRev2(sender: UISwitch) {
        var command:String
        command = sender.on ? "#AP-2$" : "#AP+2$";
        sendCommand(command);
        command = "#S002$";
        sendCommand(command);
    }
    
    // on change TRIM and GAIN
    func onChangeValue(view:NumericUpDownView, value:Int){
        var command:String
        
        if(view == viewTrim0){
            command = String(format: "#AO%02X0$", (value & 0xFF) )
            sendCommand(command);
            command = "#S000$";
            sendCommand(command);
        }else if(view == viewTrim1){
            command = String(format: "#AO%02X1$", (value & 0xFF) )
            sendCommand(command);
            command = "#S000$";
            sendCommand(command);
        }else if(view == viewTrim2){
            command = String(format: "#AO%02X2$", (value & 0xFF) )
            sendCommand(command);
            command = "#S000$";
            sendCommand(command);
        }else if(view == viewGain0){
            command = String(format: "#AA%02X0$", (value & 0xFF) )
            sendCommand(command);
            command = "#S000$";
            sendCommand(command);
        }else if(view == viewGain1){
            command = String(format: "#AA%02X1$", (value & 0xFF) )
            sendCommand(command);
            command = "#S000$";
            sendCommand(command);
        }else if(view == viewGain2){
            command = String(format: "#AA%02X2$", (value & 0xFF) )
            sendCommand(command);
            command = "#S000$";
            sendCommand(command);
        }
    }
    
    // send command
    func sendCommand(command:String)
    {
        if(!Konashi.isConnected()) {return}
        Konashi.uartWriteString(command)
    }

    // 4WS picker
    // number of col
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    // number of row
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return MODE_4WS_LIST.count
    }
    // value for view
    //    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    //        return MODE_4WS_LIST[row] as String
    //    }
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        
        let pickerLabel = UILabel()
        let titleData = MODE_4WS_LIST[row] as String
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "HiraKakuProN-W3", size: 16.0)!,NSForegroundColorAttributeName:UIColor.blackColor()])
        
        pickerLabel.attributedText = myTitle
        pickerLabel.textAlignment = NSTextAlignment.Center
        pickerLabel.frame = CGRectMake(0, 0, 200, 30)
        pickerLabel.layer.masksToBounds = true
        pickerLabel.layer.cornerRadius = 5.0
        
        return pickerLabel
    }
    
    // on change 4WS picker
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //mode4ws = row
        switch(row){
        // [FRONT]
        case 0:
            mode4ws = MODE_FRONT;
            break;
        // [REAR]
        case 1:
            mode4ws = MODE_REAR;
            break;
        // [NORMAL]
        case 2:
            mode4ws = MODE_COMMON;
            break;
        // [REVERSE]
        case 3:
            mode4ws = MODE_REVERSE;
            break;
        default:
            picker4WS.selectRow(0, inComponent:0, animated:false);
            break;
        }
        // 4WS Mode
        let ud = NSUserDefaults.standardUserDefaults()
        ud.setInteger(mode4ws, forKey: "mode4ws")
        ud.synchronize()
    }

    // on receive UART command
    func onCommandReceived(data:[UInt8])
    {
        var hexString:String
        let strData = NSString(bytes: data, length: data.count, encoding: NSASCIIStringEncoding) as! String
        
        switch(data[0])
        {
            // adjust servo
            case "A".utf8.first!:
                if (data[1] == "L".utf8.first!)
                {
                    var pol = [Bool](count:3, repeatedValue: false)
                    var ofs = [Int](count:3, repeatedValue: 0)
                    var amp = [Int](count:3, repeatedValue: 0)
                    
                    for i in 0..<3
                    {
                        pol[i] = (data[2 + i * 5] == "-".utf8.first!)
                        
                        hexString = strData.substringWithRange(
                            Range(strData.startIndex.advancedBy (3 + i * 5) ..<
                                  strData.startIndex.advancedBy((3 + i * 5)+2)))
                        ofs[i] = Int(hexString, radix: 16) ?? 0
                        if (ofs[i] >= 128) {ofs[i] -= 256;}
                        
                        hexString = strData.substringWithRange(
                            Range(strData.startIndex.advancedBy (5 + i * 5) ..<
                                  strData.startIndex.advancedBy((5 + i * 5)+2)))
                        amp[i] = Int(hexString, radix: 16) ?? 0
                    }
                    dispatch_async(dispatch_get_main_queue(),{
                        self.switchRev0.on = pol[0]
                        self.switchRev1.on = pol[1]
                        self.switchRev2.on = pol[2]
                        self.viewTrim0.setValue(ofs[0])
                        self.viewTrim1.setValue(ofs[1])
                        self.viewTrim2.setValue(ofs[2])
                        self.viewGain0.setValue(amp[0])
                        self.viewGain1.setValue(amp[1])
                        self.viewGain2.setValue(amp[2])
                        self.sendCommand("#S000$")
                        self.sendCommand("#S001$")
                        self.sendCommand("#S002$")
                    })
                }
                break;
            // battery voltage
            case "B".utf8.first!:
                hexString = strData.substringWithRange(
                    Range(strData.startIndex.advancedBy(1) ..<
                          strData.startIndex.advancedBy(1+3)))
                let adc:Int = Int(hexString, radix: 16) ?? 0
                let voltage:Double = Double(adc) * 2 * 3.3 / 1024;
                
                dispatch_async(dispatch_get_main_queue(),{
                    self.textVbat.text = String(format:"%5.2f V", voltage)
                })
                break;
            
            default:
                break;
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
