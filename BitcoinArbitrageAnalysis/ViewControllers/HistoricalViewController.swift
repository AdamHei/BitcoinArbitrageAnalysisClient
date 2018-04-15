import UIKit
import Charts

class HistoricalViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, ChartViewDelegate, HistoricalServiceDelegate {

    enum PickerViewTag: Int {
        case Exchange1
        case Exchange2
        case Interval
    }
    
    @IBOutlet weak var exchange1TextField: UITextField!
    @IBOutlet weak var exchange2TextField: UITextField!
    @IBOutlet weak var intervalTextField: UITextField!
    
    @IBOutlet weak var deltaLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var exchange1PriceLabel: UILabel!
    @IBOutlet weak var exchange2PriceLabel: UILabel!
    @IBOutlet weak var exchange1Label: UILabel!
    @IBOutlet weak var exchange2Label: UILabel!
    
    @IBOutlet weak var historicalLineChart: LineChartView!
    
    let historicalDataService = HistoricalDataService()
    
    // For the Delta timestamp
    let dateFormatter = DateFormatter()
    
    var exchange1 = INDEX
    var exchange2 = GDAX
    var interval = "YEAR"
    
    let exchanges = [INDEX, BINANCE, GDAX, BITFINEX, KRAKEN, GEMINI]
    
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
        
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
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
        historicalLineChart.xAxis.setLabelCount(3, force: true)
        historicalLineChart.xAxis.avoidFirstLastClippingEnabled = true
        historicalLineChart.xAxis.labelPosition = XAxis.LabelPosition.bottom
    }
    
    func didReceiveDataPoints(_ datapoints: [DataPoint], _ exchange: Exchange) {
        // Cannot update a view from a background thread
        DispatchQueue.main.async {
            self.addNewDataPointsToChart(Datapoints: datapoints, Exchange: exchange)
        }
    }
    
    // Possible issue: Server requests arrive in order of Exchange 2 then Exchange 1
    // 
    func addNewDataPointsToChart(Datapoints datapoints: [DataPoint], Exchange exchange: Exchange) {
        // Data points are returned descending from the server
        let dataPointsAscending = datapoints.reversed()
        
        print("Found \(dataPointsAscending.count) buckets from \(exchange.displayName)")
        
        // Map server response to array of DataPoints
        let historicalDataPoints = dataPointsAscending.map { (datapoint) -> ChartDataEntry in
            return ChartDataEntry(x: Double(datapoint.timestamp), y: Double(datapoint.price)!)
        }
        
        let historicalDataSet = LineChartDataSet(values: historicalDataPoints, label: exchange.displayName)
        historicalDataSet.colors = [exchange.color]
        historicalDataSet.drawCirclesEnabled = false
        historicalDataSet.label = exchange.displayName
        
        var historicalData: LineChartData
        if (historicalLineChart.data != nil) {
            historicalData = historicalLineChart.data! as! LineChartData
            
            if exchange == exchange1 && historicalData.dataSetCount > 0 {
                // There's already a dataset in the chart, and
                // we need to insert in front of it to maintain exchange1 before exchange2 ordering
                let exchange2DataSet = historicalData.getDataSetByIndex(0)
                historicalData.removeDataSetByIndex(0)
                historicalData.addDataSet(historicalDataSet)
                historicalData.addDataSet(exchange2DataSet)
            } else {
                historicalData.addDataSet(historicalDataSet)
            }
        } else {
            historicalData = LineChartData()
            historicalData.addDataSet(historicalDataSet)
        }
        
        historicalLineChart.data = historicalData
        historicalLineChart.data?.setDrawValues(false)
        historicalLineChart.notifyDataSetChanged()
        
        historicalLineChart.chartDescription?.text = ""
    }

    // Update arbitrage related labels when user selects a point on the chart
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        if historicalLineChart.data!.dataSetCount < 2 {
            print("There are fewer than two data sets in the chart => No useful arbitrage data")
            return
        }
        
        // The data set the user just so happened to tap on
        // Depends on whether the user tapped above or below the lines, which they aren't aware of
        let dataSetIndex = highlight.dataSetIndex
        
        let timestamp = entry.x
        var exchange1Val = 0.0, exchange2Val = 0.0
        let isExchange1 = dataSetIndex == 0
        
        var complementDataSet: ChartDataSet
        if isExchange1 {
            exchange1Val = entry.y
            complementDataSet = historicalLineChart.data!.getDataSetByIndex(1) as! ChartDataSet
            
            // Find the corresponding point at the same timestamp or closest to
            // Ideally, the server has given us well-aligned data so we don't need to search beyond the x-value
            if let entry = complementDataSet.entryForXValue(timestamp, closestToY: exchange1Val) {
                exchange2Val = entry.y
            }
        } else {
            exchange2Val = entry.y
            complementDataSet = historicalLineChart.data!.getDataSetByIndex(0) as! ChartDataSet
            
            // See above comment
            if let entry = complementDataSet.entryForXValue(timestamp, closestToY: exchange2Val) {
                exchange1Val = entry.y
            }
        }
        
        let date = Date(timeIntervalSince1970: timestamp)
        timeLabel.text = dateFormatter.string(from: date)
        
        if exchange1Val != 0.0 && exchange2Val != 0.0 {
            // We have useful data to display
            let delta = abs(exchange1Val - exchange2Val)
            deltaLabel.text = String(format: "$%.2f", delta)
            exchange1PriceLabel.text = String(format: "$%.2f", exchange1Val)
            exchange2PriceLabel.text = String(format: "$%.2f", exchange2Val)
        } else if exchange1Val != 0 {
            exchange1PriceLabel.text = String(format: "$%.2f", exchange1Val)
            exchange2PriceLabel.text = "N/A"
            deltaLabel.text = "N/A"
        } else {
            exchange2PriceLabel.text = String(format: "$%.2f", exchange2Val)
            exchange1PriceLabel.text = "N/A"
            deltaLabel.text = "N/A"
        }
    }

    // Only one column in each pickerview
    // Could condense all pickerviews into one 3-column view to save space
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
    
    // Update labels and exchange/interval related vars when user selects an option
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let tag = PickerViewTag(rawValue: pickerView.tag) {
            switch tag {
            case PickerViewTag.Exchange1:
                exchange1 = exchanges[row]
                exchange1TextField.text = exchange1.displayName
                exchange1Label.text = "\(exchange1.displayName):"
                print("Exchange 1 is now \(exchange1)")
            case PickerViewTag.Exchange2:
                exchange2 = exchanges[row]
                exchange2TextField.text = exchange2.displayName
                exchange2Label.text = "\(exchange2.displayName):"
                print("Exchange 2 is now \(exchange2)")
            case PickerViewTag.Interval:
                intervalTextField.text = intervals[row].displayInterval
                interval = intervals[row].interval
                print("Interval is now \(interval)")
            }
        }
    }
    
    // Clear old data and fetch new exchange data
    @IBAction func didTapFetchButton(_ sender: UIButton) {
        historicalLineChart.clear()
        historicalDataService.loadHistoricalData(Exchange: exchange1, Interval: interval)
        historicalDataService.loadHistoricalData(Exchange: exchange2, Interval: interval)
    }

    // Clear the line chart data and the arbitrage related labels
    @IBAction func didTapClearButton(_ sender: UIButton) {
        historicalLineChart.clear()
        exchange1PriceLabel.text = ""
        exchange2PriceLabel.text = ""
        deltaLabel.text = ""
        timeLabel.text = ""
    }
    
    // Dismiss the pickerview when tapped outside
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}
