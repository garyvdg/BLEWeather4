//
//  UartModuleViewController.swift
//  Basic Chat
//
//  Created by Trevor Beaton on 12/4/16.
//  Copyright © 2016 Vanguard Logic LLC. All rights reserved.
//  Modified by Gary Vandergaast 2018 November 1

import UIKit
import CoreBluetooth
import SwiftChart

class UartModuleViewController: UIViewController, CBPeripheralManagerDelegate, ChartDelegate {
    
    //UI
    
    @IBOutlet weak var chart: Chart!
    @IBOutlet weak var blinkLamp: UILabel!
    @IBOutlet weak var humLabel: UILabel!
    @IBOutlet weak var newLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var switchUI: UISwitch!
    @IBOutlet weak var battColor: UILabel!
    //Data
    var peripheralManager: CBPeripheralManager?
    var peripheral: CBPeripheral!
    private var consoleAsciiText:NSAttributedString? = NSAttributedString(string: "")
    
    var counter : Int = 0
    var tValue : Double = 0.0
    var tempData : Double = 0.0
    
    // var tempDataArray = Array(repeating: 0.0, count: 360)
    var tempDataArray : [Double] = []
    
    var blinker : Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        blinkLamp.text = ""
        chart.delegate = self
        
        let userDefaults = UserDefaults.standard
        chart.maxY = Double(userDefaults.integer(forKey: "graphMax"))
        chart.minY = Double(userDefaults.integer(forKey: "baseValue"))
        
//        let offSet = chart.minY! + 8.0
//
//        for index in 0...359 {
//            tempDataArray[index] = offSet
//        }
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"Back", style:.plain, target:nil, action:nil)
        
        //Create and start the peripheral manager
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        chart.gridColor = UIColor.white
        // chart.showXLabelsAndGrid = false
        chart.xLabels = [0, 60, 120, 180, 240, 300, 360]
        //-Notification for updating the text view with incoming text
        updateIncomingData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
    
    }
    
    override func viewDidDisappear(_ animated: Bool) {

        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func goToChart(_ sender: Any) {
        performSegue(withIdentifier: "goToChartView", sender: self)
        
    }
    
    func updateIncomingData () {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "Notify"), object: nil , queue: nil){
            notification in
            var strLength: Int
            self.counter = self.counter + 1
            // let appendString = "\n"
            let leadSpace = "*"
            let tempUnits = "\u{00B0} C"
            let humUnits = " % RH"
            let labelString = leadSpace + (characteristicASCIIValue as String)
            
            strLength = labelString.count
            
            if strLength == 19 {
            let TSindex = labelString.index(labelString.startIndex, offsetBy: 2)
            let TEindex = labelString.index(labelString.startIndex, offsetBy: 8)
            let HSindex = labelString.index(labelString.startIndex, offsetBy: 12)
            let HEindex = labelString.index(labelString.endIndex, offsetBy: -2)
            let battIndexS = labelString.index(labelString.startIndex, offsetBy: 18)
            let battIndexE = labelString.index(labelString.endIndex, offsetBy: 0)
            
            let Trange = TSindex..<TEindex
            let Hrange = HSindex..<HEindex
            let battRange = battIndexS..<battIndexE
                
            var tempString = String(labelString[Trange])
                print(tempString)
            var humString = String(labelString[Hrange])
            
                if let tempFloat = NumberFormatter().number(from: tempString) {
                
                        
                    self.tValue = tempFloat.doubleValue
                        self.tempData = self.tempData + self.tValue
                        
                    }
    
                print(self.tempData)

            tempString = tempString + tempUnits
            humString = humString + humUnits
            self.newLabel.text = tempString
            self.humLabel.text = humString
     
                if self.blinker == true {
                    self.blinkLamp.backgroundColor = UIColor.red
                    self.blinker = false
                } else {
                    self.blinkLamp.backgroundColor = UIColor.orange
                    self.blinker = true
                }
                
            let battValue = String(labelString[battRange])
                
                if battValue == "b"
                {
                    self.battColor.backgroundColor = UIColor.blue
                    self.battColor.textColor = UIColor.white
                }
                else
                    if battValue == "g"
                    {
                    self.battColor.backgroundColor = UIColor.green
                    self.battColor.textColor = UIColor.black
                    }
                else
                    if battValue == "y"
                    {
                    self.battColor.backgroundColor = UIColor.yellow
                    self.battColor.textColor = UIColor.blue
                    }
                else
                    if battValue == "o"
                    {
                    self.battColor.backgroundColor = UIColor.orange
                    self.battColor.textColor = UIColor.black
                    }
                else
                    if battValue == "r"
                    {
                    self.battColor.backgroundColor = UIColor.red
                    self.battColor.textColor = UIColor.black
                    }
                        
                else {
                    self.battColor.backgroundColor = UIColor.black
                    self.battColor.textColor = UIColor.black
                    }
            }
            
            // print(self.counter)
            if self.counter > 4 {
                
                if self.tempDataArray.count < 60 {
                    self.chart.xLabels = [0, 15, 30, 45, 60]
                } else
                    if self.tempDataArray.count < 180 {
                        self.chart.xLabels = [0, 60, 120, 180]
                } else {
                    self.chart.xLabels = [0, 60, 120, 180, 240, 300, 360]
                }
                
                
                
                if self.tempDataArray.count >= 360 {
                    self.tempDataArray.remove(at: 0)
                }
                
                self.tempDataArray.append(self.tempData / 5.0)
                self.tempData = 0
                self.counter = 0
                self.chart.removeAllSeries()
                let series = ChartSeries(self.tempDataArray)
                series.color = ChartColors.yellowColor()
                
                self.chart.add(series)
            }
        }
 
    }
    
    // Write functions
    func writeValue(data: String){
        let valueString = (data as NSString).data(using: String.Encoding.utf8.rawValue)
        //change the "data" to valueString
        if let blePeripheral = blePeripheral{
            if let txCharacteristic = txCharacteristic {
                blePeripheral.writeValue(valueString!, for: txCharacteristic, type: CBCharacteristicWriteType.withResponse)
            }
        }
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            return
        }
        print("Peripheral manager is running")
    }
    
    //Check when someone subscribe to our characteristic, start sending the data
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        print("Device subscribe to characteristic")
    }
    
    //This on/off switch sends a value of 1 and 0 to the Arduino
    //This can be used as a switch or any thing you'd like
    @IBAction func switchAction(_ sender: Any) {
        if switchUI.isOn {
            print("On ")
            writeValue(data: "1")
        }
        else
        {
            print("Off")
            writeValue(data: "0")
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        // outgoingData()
        return(true)
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if let error = error {
            print("\(error)")
            return
        }
    }
    
    // Chart delegate
    
    func didTouchChart(_ chart: Chart, indexes: Array<Int?>, x: Double, left: CGFloat) {
        for (seriesIndex, dataIndex) in indexes.enumerated() {
            if let value = chart.valueForSeries(seriesIndex, atIndex: dataIndex) {
                print("Touched series: \(seriesIndex): data index: \(dataIndex!); series value: \(value); x-axis value: \(x) (from left: \(left))")
            }
        }
    }
    
    func didFinishTouchingChart(_ chart: Chart) {
        
    }
    
    func didEndTouchingChart(_ chart: Chart) {
        
    }
}

