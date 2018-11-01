//
//  ChartViewController.swift
//  BLEWeather
//
//  Created by Gary Vandergaast on 2018-10-30.
//  Copyright © 2018 Vanguard Logic LLC. All rights reserved.
//

import UIKit
import CoreBluetooth

class ChartViewController: UIViewController, CBPeripheralManagerDelegate {
    
    @IBOutlet weak var rawDataList: UITextView!
    var periferalManager : CBPeripheralManager?
    var periferal : CBPeripheral!
    private var buildupAsciiText:NSAttributedString? = NSAttributedString(string: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        periferalManager = CBPeripheralManager(delegate: self, queue: nil)
        self.rawDataList.text = ""
        updateRawData ()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver((Any).self)
    }

    func updateRawData () {
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "Notify"), object: nil , queue: nil){
            notification in
        
            let addToString = "\n"
            var countValue : Int = 0
            
            let thisFont = UIFont(name: "Helvetica Neue", size: 18.0)
            let myAttributes3 = [NSAttributedString.Key.font: thisFont!, NSAttributedString.Key.foregroundColor: UIColor.darkGray]
            
            countValue = self.rawDataList.text.count
            // print(countValue)
            
            let modString = NSAttributedString(string: "   " + (characteristicASCIIValue as String) + addToString, attributes: myAttributes3)
            let textText = NSMutableAttributedString(attributedString: self.buildupAsciiText!)

            textText.append(modString)
    
            self.buildupAsciiText = textText
            self.rawDataList.attributedText = self.buildupAsciiText
            
            if countValue >= 562 {
                self.buildupAsciiText = NSAttributedString(string: "")
            }
        }
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            return
        }
        print("Peripheral manager is running")
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    
}
