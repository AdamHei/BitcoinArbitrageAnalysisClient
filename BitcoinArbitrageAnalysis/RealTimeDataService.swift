//
//  RealTimeDataService.swift
//  BitcoinArbitrageAnalysis
//
//  Created by Adam Heimendinger on 2/18/18.
//  Copyright © 2018 Adam Heimendinger. All rights reserved.
//

import Foundation

struct Ticker: Decodable {
    var exchange: String
    var bid: String
    var ask: String
}

protocol RealTimeServiceDelegate: class {
    func didReceiveTickers(_ tickers: [Ticker])
}

class RealTimeDataService {
    weak var delegate: RealTimeServiceDelegate?
    
    private let allSpreadUrl = URL(string: "http://104.236.221.68:81/live-spread/all")!
    private let widestSpreadUrl = URL(string: "http://104.236.221.68:81/live-spread/widest")!
    private let session: URLSession = .shared
    private let decoder = JSONDecoder()
    
    func fetchAllSpreadData() {
        let task = session.dataTask(with: allSpreadUrl) { (data, response, error) in
            if error != nil {
                print("Could not retrieve all spread data")
                print(error!)
                return
            }
            do {
                let tickers = try self.decoder.decode([Ticker].self, from: data!)
                self.delegate?.didReceiveTickers(tickers)
            } catch let error {
                print("Could not decode Tickers")
                print(error)
            }
        }
        task.resume()
    }
}
