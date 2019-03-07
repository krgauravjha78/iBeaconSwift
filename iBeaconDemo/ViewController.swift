//
//  ViewController.swift
//  iBeaconDemo
//
//  Created by Gaurav on 07/03/19.
//  Copyright © 2019 iWizards XI. All rights reserved.
//

import UIKit
import CoreLocation
import CoreBluetooth
import QuartzCore

class ViewController: UIViewController, CBPeripheralManagerDelegate, UITextFieldDelegate {
    
    @IBOutlet var lblStatus: UILabel!
    @IBOutlet var lblBTStatus: UILabel!
    @IBOutlet var txtMajor: UITextField!
    @IBOutlet var txtMinor: UITextField!
    @IBOutlet var btnStart: UIButton!
    
    //I have placed static value Can use the commented code for getting device UDID
//    let uuidString = UIDevice.current.identifierForVendor
    let uuid = NSUUID(uuidString: "F34A1A1F-500F-48FB-AFAA-9584D641D7B1")
    
    var beaconRegion: CLBeaconRegion!
    var bluetoothPeripheralManager: CBPeripheralManager!
    var isBroadcasting = false
    var dataDictionary = NSDictionary()

    override func viewDidLoad() {
        super.viewDidLoad()
        txtMajor.text = ""
        txtMinor.text = ""
        txtMinor.delegate = self
        txtMajor.delegate = self
        let swipeDownGestureRecognizer = UISwipeGestureRecognizer(target: self, action: Selector(("handleSwipeGestureRecognizer:")))
        swipeDownGestureRecognizer.direction = UISwipeGestureRecognizer.Direction.down
        view.addGestureRecognizer(swipeDownGestureRecognizer)
        bluetoothPeripheralManager = CBPeripheralManager(delegate: self as CBPeripheralManagerDelegate, queue: nil, options: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Custom method implementation
    func handleSwipeGestureRecognizer(gestureRecognizer: UISwipeGestureRecognizer) {
        txtMajor.resignFirstResponder()
        txtMinor.resignFirstResponder()
    }
    
    // MARK: To Dismiss the keyboard called when 'return' key pressed. return NO to ignore.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true;
    }
    
    // MARK: IBAction method implementation
    @IBAction func switchBroadcastingState(sender: AnyObject) {
        
        if txtMajor.text == "" || txtMinor.text == "" {
            return
        }
        if txtMajor.isFirstResponder || txtMinor.isFirstResponder {
            return
        }
        
        if !isBroadcasting {
            if bluetoothPeripheralManager.state == CBManagerState.poweredOn {
                if bluetoothPeripheralManager.state == CBManagerState.poweredOn {
                    let major: CLBeaconMajorValue = UInt16(txtMajor.text!)!
                    let minor: CLBeaconMinorValue = UInt16(txtMinor.text!)!
                    beaconRegion = CLBeaconRegion(proximityUUID: uuid! as UUID, major: major, minor: minor, identifier: "Krgauravjha78@gmail.com")
                    dataDictionary = beaconRegion.peripheralData(withMeasuredPower: nil)
                    bluetoothPeripheralManager.startAdvertising(dataDictionary as? [String : Any])
                    btnStart.setTitle("Stop", for: UIControl.State.normal)
                    lblStatus.text = "Broadcasting Signal..."
                    txtMajor.isEnabled = false
                    txtMinor.isEnabled = false
                    isBroadcasting = true
                }
            }
        }
        else{
            bluetoothPeripheralManager.stopAdvertising()
            btnStart.setTitle("Start", for: UIControl.State.normal)
            lblStatus.text = "Stopped"
            txtMajor.isEnabled = true
            txtMinor.isEnabled = true
            isBroadcasting = false
        }
    }

    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        var statusMessage = ""

        //to determine the bluetooth status of device , in which state it is.
        switch peripheral.state {
        case CBManagerState.poweredOn:
            statusMessage = "Bluetooth Status is: On"
            
        case CBManagerState.poweredOff:
            if isBroadcasting {
                switchBroadcastingState(sender: self)
            }
            statusMessage = "Bluetooth Status is: Off"
            
        case CBManagerState.resetting:
            statusMessage = "Bluetooth Status is: Resetting"
            
        case CBManagerState.unauthorized:
            statusMessage = "Bluetooth Status is: Not Authorized"
            
        case CBManagerState.unsupported:
            statusMessage = "Bluetooth Status is: Not Supported"
            
        default:
            statusMessage = "Bluetooth Status is: Unknown"
        }
        lblBTStatus.text = statusMessage
    }

}

