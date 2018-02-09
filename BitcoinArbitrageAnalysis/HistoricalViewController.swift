//
//  SecondViewController.swift
//  BitcoinArbitrageAnalysis
//
//  Created by Adam Heimendinger on 1/28/18.
//  Copyright © 2018 Adam Heimendinger. All rights reserved.
//

import UIKit
import Charts

class HistoricalViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, ChartViewDelegate, DataServiceDelegate {

    enum PickerViewTag: Int {
        case Exchange1
        case Exchange2
        case Interval
    }
    
    @IBOutlet weak var exchange1TextField: UITextField!
    @IBOutlet weak var exchange2TextField: UITextField!
    @IBOutlet weak var intervalTextField: UITextField!
    @IBOutlet weak var indexSwitch: UISwitch!
    
    @IBOutlet weak var historicalLineChart: LineChartView!
    @IBOutlet weak var selectedValueLabel: UILabel!
    
    let historicalDataService = HistoricalDataService()
    
    var exchange1 = GDAX
    var exchange2 = BITFINEX
    var interval = "YEAR"
    var withIndex = false
    
    let exchanges = [GDAX, BITFINEX, KRAKEN, GEMINI]
    
    let intervals:[(interval: String, displayInterval: String)] = [("TWOYEAR", "Two Years"),
                                                                   ("YEAR", "One Year"),
                                                                   ("SIXMONTH", "Six Months"),
                                                                   ("THREEMONTH", "Three Months"),
                                                                   ("MONTH", "One Month"),
                                                                   ("WEEK", "One Week"),
                                                                   ("DAY", "One Day")]
    
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
        
        historicalLineChart.delegate = self
        historicalDataService.delegate = self
        initChart()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initChart() {
        historicalLineChart.xAxis.valueFormatter = XAxisFormatter()
        historicalLineChart.xAxis.setLabelCount(2, force: false)
        historicalLineChart.xAxis.avoidFirstLastClippingEnabled = true
        historicalLineChart.xAxis.labelPosition = XAxis.LabelPosition.bottom
        
//        historicalLineChart.data = LineChartData()
        historicalLineChart.data?.setDrawValues(false)
    }
    
    func didReceiveDataPoints(_ datapoints: [DataPoint], _ exchange: Exchange) {
        DispatchQueue.main.async {
            self.addNewDataPointsToChart(Datapoints: datapoints, Exchange: exchange)
        }
    }
    
    func addNewDataPointsToChart(Datapoints datapoints: [DataPoint], Exchange exchange: Exchange) {
        // Data points are returned descending from the server
        let dataPointsAscending = datapoints.reversed()
        
        print("Found \(dataPointsAscending.count) buckets from \(exchange.displayName)")
        
        // Map server response to array of DataPoints
        let historicalDataPoints = dataPointsAscending.map { (datapoint) -> ChartDataEntry in
            return ChartDataEntry(x: Double(datapoint.timestamp), y: Double(datapoint.price!)!)
        }
        
        let historicalDataSet = LineChartDataSet(values: historicalDataPoints, label: exchange.displayName)
        historicalDataSet.colors = [exchange.color]
        historicalDataSet.drawCirclesEnabled = false
        
        var historicalData: LineChartData
        if (historicalLineChart.data != nil) {
            historicalData = historicalLineChart.data! as! LineChartData
        } else {
            historicalData = LineChartData()
        }
        historicalData.addDataSet(historicalDataSet)
        
        historicalLineChart.data = historicalData
        historicalLineChart.notifyDataSetChanged()
        
        historicalLineChart.chartDescription?.text = ""
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        selectedValueLabel.text = String(format: "%f", entry.y)
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
                return exchanges[row].displayName
            case PickerViewTag.Exchange2:
                return exchanges[row].displayName
            case PickerViewTag.Interval:
                return intervals[row].displayInterval
            }
        }
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let tag = PickerViewTag(rawValue: pickerView.tag) {
            switch tag {
            case PickerViewTag.Exchange1:
                exchange1TextField.text = exchanges[row].displayName
                exchange1 = exchanges[row]
                print("Exchange 1 is now \(exchange1)")
            case PickerViewTag.Exchange2:
                exchange2TextField.text = exchanges[row].displayName
                exchange2 = exchanges[row]
                print("Exchange 2 is now \(exchange2)")
            case PickerViewTag.Interval:
                intervalTextField.text = intervals[row].displayInterval
                interval = intervals[row].interval
                print("Interval is now \(interval)")
            }
        }
    }
    
    @IBAction func didTapFetchButton(_ sender: UIButton) {
        historicalLineChart.clear()
        historicalDataService.loadHistoricalData(Exchange: exchange1, Interval: interval)
        historicalDataService.loadHistoricalData(Exchange: exchange2, Interval: interval)
    }

    // Clear the line chart data
    @IBAction func didTapClearButton(_ sender: UIButton) {
        historicalLineChart.clear()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}
