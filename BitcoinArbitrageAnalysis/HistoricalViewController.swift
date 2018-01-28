//
//  SecondViewController.swift
//  BitcoinArbitrageAnalysis
//
//  Created by Adam Heimendinger on 1/28/18.
//  Copyright © 2018 Adam Heimendinger. All rights reserved.
//

import UIKit

class HistoricalViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    enum PickerViewTag: Int {
        case Exchange1
        case Exchange2
        case Interval
    }
    
    @IBOutlet weak var exchange1TextField: UITextField!
    @IBOutlet weak var exchange2TextField: UITextField!
    @IBOutlet weak var intervalTextField: UITextField!
    
    @IBOutlet weak var indexSwitch: UISwitch!
    
    var exchange1 = "", exchange2 = "", interval = ""
    var withIndex = false
    
    let exchanges = ["Bitfinex", "GDAX", "Kraken", "Gemini"]
    let intervals = ["Two Years", "One Year", "Six Months", "Three Months", "One Month", "One Week", "One Day", "12 Hour", "Six Hour", "One Hour", "30 Minute"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Exchange 1 Picker setup
        let exchange1PickerView = UIPickerView()
        exchange1PickerView.tag = PickerViewTag.Exchange1.rawValue
        exchange1PickerView.delegate = self
        
        // Exhcange 2 Picker setup
        let exchange2PickerView = UIPickerView()
        exchange2PickerView.tag = PickerViewTag.Exchange2.rawValue
        exchange2PickerView.delegate = self
        
        // Interval Picker setup
        let intervalPickerView = UIPickerView()
        intervalPickerView.tag = PickerViewTag.Interval.rawValue
        intervalPickerView.delegate = self
        
        exchange1TextField.inputView = exchange1PickerView
        exchange2TextField.inputView = exchange2PickerView
        intervalTextField.inputView = intervalPickerView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        let tag = PickerViewTag(rawValue: pickerView.tag)
        
        if tag == PickerViewTag.Exchange1 || tag == PickerViewTag.Exchange2 {
            return exchanges.count
        } else {
            return intervals.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if let tag = PickerViewTag(rawValue: pickerView.tag) {
            switch tag {
            case PickerViewTag.Exchange1:
                return exchanges[row]
            case PickerViewTag.Exchange2:
                return exchanges[row]
            case PickerViewTag.Interval:
                return intervals[row]
            }
        }
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let tag = PickerViewTag(rawValue: pickerView.tag) {
            switch tag {
            case PickerViewTag.Exchange1:
                exchange1TextField.text = exchanges[row]
                exchange1 = exchanges[row]
            case PickerViewTag.Exchange2:
                exchange2TextField.text = exchanges[row]
                exchange2 = exchanges[row]
            case PickerViewTag.Interval:
                intervalTextField.text = intervals[row]
                interval = intervals[row]
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}
