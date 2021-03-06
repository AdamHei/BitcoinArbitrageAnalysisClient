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

//{
//    "btcQuantity": "0.002059",
//    "buyExchange": "Bitfinex",
//    "buyPrice": "8051.9",
//    "buyQuantity": "36.32705524",
//    "buyTakerFee": "0.2",
//    "buyWithdrawalFee": "0.0004",
//    "hasWithdrawalFee": true,
//    "profit": "-3.26",
//    "sellExchange": "Binance",
//    "sellPrice": "8056.01",
//    "sellQuantity": "0.00205900",
//    "sellTakerFee": "0.1"
//}

struct WidestSpread: Decodable {
    var buyExchange: String
    var buyPrice: String
    var buyQuantity: String
    var buyTakerFee: String
    var buyWithdrawalFee: String
    
    var profit: String
    var btcQuantity: String
    var hasWithdrawalFee: Bool
    
    var sellExchange: String
    var sellPrice: String
    var sellQuantity: String
    var sellTakerFee: String
}

protocol RealTimeServiceDelegate: class {
    func didReceiveTickers(_ tickers: [Ticker])
    func didReceiveWidestSpread(_ spread: WidestSpread)
}

class RealTimeDataService {
    weak var delegate: RealTimeServiceDelegate?
    
    private let allSpreadUrl = URL(string: "http://104.236.221.68:81/live-spread/all")!
    private let widestSpreadUrl = URL(string: "http://104.236.221.68:81/live-spread/widest")!
    private let session: URLSession = .shared
    private let decoder = JSONDecoder()
    
    func fetchAllSpreads() {
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
    
    func fetchWidestSpread() {
        let task = session.dataTask(with: widestSpreadUrl) { (data, response, error) in
            if error != nil {
                print("Could not retrieve widest spread")
                print(error!)
                return
            }
            do {
                let spread = try self.decoder.decode(WidestSpread.self, from: data!)
                self.delegate?.didReceiveWidestSpread(spread)
            } catch let error {
                print("Could not decode widest spread data")
                print(error)
            }
        }
        task.resume()
    }
}
