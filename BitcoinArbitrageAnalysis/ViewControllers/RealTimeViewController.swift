//
//  FirstViewController.swift
//  BitcoinArbitrageAnalysis
//
//  Created by Adam Heimendinger on 1/28/18.
//  Copyright © 2018 Adam Heimendinger. All rights reserved.
//

import UIKit

class RealTimeViewController: UIViewController, RealTimeServiceDelegate {
    
    @IBOutlet weak var arbitrageView: ArbitrageView!
    
    let realTimeDataService = RealTimeDataService()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        realTimeDataService.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func didTapFetchButton(_ sender: UIButton) {
        realTimeDataService.fetchWidestSpread()
    }
    
    func didReceiveTickers(_ tickers: [Ticker]) {

    }
    
    func didReceiveWidestSpread(_ spread: WidestSpread) {
        DispatchQueue.main.async {
            self.arbitrageView.displayOpportunity(spread)
        }
    }
}
