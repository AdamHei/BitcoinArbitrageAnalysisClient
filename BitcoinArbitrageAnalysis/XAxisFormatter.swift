//
//  XAxisFormatter.swift
//  BitcoinArbitrageAnalysis
//
//  Created by Adam Heimendinger on 2/8/18.
//  Copyright © 2018 Adam Heimendinger. All rights reserved.
//

import Foundation
import Charts

class XAxisFormatter: IAxisValueFormatter {
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let date = Date(timeIntervalSince1970: value)
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        return dateFormatter.string(from: date)
    }
}
