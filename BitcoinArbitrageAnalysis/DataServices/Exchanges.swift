//
//  Exchanges.swift
//  BitcoinArbitrageAnalysis
//
//  Created by Adam Heimendinger on 2/8/18.
//  Copyright © 2018 Adam Heimendinger. All rights reserved.
//

import Foundation
import UIKit

struct Exchange {
    let name: String
    let displayName: String
    let color: UIColor
}

let GDAX = Exchange(name: "gdax", displayName: "GDAX", color: UIColor.blue)
let BITFINEX = Exchange(name: "bitfinex", displayName: "Bitfinex", color: UIColor.red)
let KRAKEN = Exchange(name: "kraken", displayName: "Kraken", color: UIColor.cyan)
//let GEMINI = Exchange(name: "gemini", displayName: "Gemini", color: UIColor.green)
let INDEX = Exchange(name: "index", displayName: "Index", color: UIColor.purple)
let BINANCE = Exchange(name: "binance", displayName: "Binance", color: UIColor.orange)
let BITSTAMP = Exchange(name: "bitstamp", displayName: "Bitstamp", color: UIColor.green)

extension Exchange: Equatable {
    static func ==(lhs: Exchange, rhs: Exchange) -> Bool {
        return lhs.name == rhs.name
    }
}
