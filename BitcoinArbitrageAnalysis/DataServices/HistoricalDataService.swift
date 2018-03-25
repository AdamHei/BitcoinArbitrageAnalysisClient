//
//  HistoricalDataService.swift
//  BitcoinArbitrageAnalysis
//
//  Created by Adam Heimendinger on 2/8/18.
//  Copyright © 2018 Adam Heimendinger. All rights reserved.
//

import Foundation

struct DataPoint: Decodable {
    var timestamp: Int
    var price: String
}

protocol HistoricalServiceDelegate: class {
    func didReceiveDataPoints(_ datapoints: [DataPoint], _ exchange: Exchange)
    // TODO Add error handling function
}

class HistoricalDataService {
    weak var delegate: HistoricalServiceDelegate?
    
    private let serverIP = "104.236.221.68"
    private let tempurl = "http://104.236.221.68/historical/%@/%@"
    private let session: URLSession = .shared
    
    func loadHistoricalData(Exchange exchange: Exchange, Interval interval: String) {
        let urlString = String(format: tempurl, exchange.name, interval)
        let url = URL(string: urlString)!
        
        let task = session.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print("We could not fetch data from the server")
                return
            }
            do {
                let decoder = JSONDecoder()
                let dataPoints = try decoder.decode([DataPoint].self, from: data!)
                
                self.delegate?.didReceiveDataPoints(dataPoints, exchange)
            } catch let error {
                print(error)
            }
        }
        task.resume()
    }
}
