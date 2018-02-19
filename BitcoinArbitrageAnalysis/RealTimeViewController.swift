//
//  FirstViewController.swift
//  BitcoinArbitrageAnalysis
//
//  Created by Adam Heimendinger on 1/28/18.
//  Copyright © 2018 Adam Heimendinger. All rights reserved.
//

import UIKit

class RealTimeViewController: UIViewController, RealTimeServiceDelegate {

    let realTimeDataService = RealTimeDataService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        realTimeDataService.delegate = self
        realTimeDataService.fetchAllSpreadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func didReceiveTickers(_ tickers: [Ticker]) {
        for ticker in tickers {
            print(ticker.exchange)
        }
    }
}
