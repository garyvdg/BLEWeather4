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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        periferalManager = CBPeripheralManager(delegate: self, queue: nil)
        
        updateRawData ()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
//        periferalManager?.stopAdvertising()
//        self.periferalManager = nil
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        
    }
    

    func updateRawData () {
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "Notify"), object: nil , queue: nil){
            notification in
            let firstSpace = "* "
            // let addToString = "\n"
            let textText = firstSpace + (characteristicASCIIValue as String)
            
            print(textText)
            self.rawDataList.text = textText
            
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
