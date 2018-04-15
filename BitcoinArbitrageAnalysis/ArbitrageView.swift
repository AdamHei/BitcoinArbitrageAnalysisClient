import UIKit
import Macaw

class ArbitrageView: MacawView {
    private let WIDTH = 375.0
    private let HEIGHT = 500.0
    
    private let THREE_QUARTERS = 0.75
    private let ONE_QUARTER = 0.25
    
    private let RADIUS = 70.0
    private let SOURCE_RADIUS = 50.0
    
    private let DEFAULT_FONT = Font(name: "San Francisco", size: 13)
    
    private var arbitrageElements: [Node]
    
    required init?(coder aDecoder: NSCoder) {
        // Nodes
        let dollarImg = Image(src: "dollar.png", place: .move(dx: -25, dy: -25))
        let sourceNode = Shape(form: Circle(cx: 0, cy: 0, r: SOURCE_RADIUS), fill: Color.white, stroke: Stroke(fill: Color.black, width: 2.0))
        let sourceGroup = Group(contents: [sourceNode, dollarImg], place: .move(dx: WIDTH / 2, dy: HEIGHT * THREE_QUARTERS))
        
        let bitcoinImg = Image(src: "bitcoin.png", place: .move(dx: -25, dy: -65.0))
        let buyNode = Shape(form: Circle(cx: 0, cy: 0, r: RADIUS), fill: Color.white, stroke: Stroke(fill: Color.black, width: 2.0))
        let buyGroup = Group(contents: [buyNode, bitcoinImg], place: .move(dx: WIDTH * THREE_QUARTERS, dy: HEIGHT * ONE_QUARTER))
        
        let sellNode = Shape(form: Circle(cx: 0, cy: 0, r: RADIUS), fill: Color.white, stroke: Stroke(fill: Color.black, width: 2.0))
        let sellGroup = Group(contents: [sellNode, bitcoinImg], place: .move(dx: WIDTH * ONE_QUARTER, dy: HEIGHT * ONE_QUARTER))
        
        // Arcs
        let sourceToBuyEll = Ellipse(cx: WIDTH / 2, cy: HEIGHT * ONE_QUARTER, rx: WIDTH * ONE_QUARTER, ry: HEIGHT * 0.5)
        let sourceToBuyArc = Shape(form: sourceToBuyEll.arc(shift: 0, extent: Double.pi / 2))
        
        let buyToSellEll = Ellipse(cx: WIDTH / 2, cy: HEIGHT * ONE_QUARTER, rx: WIDTH * ONE_QUARTER, ry: 60)
        let buyToSellArc = Shape(form: buyToSellEll.arc(shift: -Double.pi, extent: -Double.pi))
        
        let sellToSourceEll = Ellipse(cx: WIDTH / 2, cy: HEIGHT * ONE_QUARTER, rx: WIDTH * ONE_QUARTER, ry: HEIGHT * 0.5)
        let sellToSourceArc = Shape(form: sellToSourceEll.arc(shift: Double.pi / 2, extent: Double.pi / 2))
        
        // Arrows
        var midPoint = (WIDTH * THREE_QUARTERS - 3.75, HEIGHT * ONE_QUARTER + RADIUS)
        var leftPoint = (midPoint.0 - 25, midPoint.1 + 30)
        var rightPoint = (midPoint.0 + 19, midPoint.1 + 30)
        let sourceToBuyArrow = Shape(form: Polyline(points: [leftPoint.0, leftPoint.1, midPoint.0, midPoint.1, rightPoint.0, rightPoint.1]))
        
        let sellNodeAngle = 48.5 * Double.pi / 180
        midPoint = (WIDTH * ONE_QUARTER + cos(sellNodeAngle) * RADIUS, HEIGHT * ONE_QUARTER - sin(sellNodeAngle) * RADIUS)
        leftPoint = (midPoint.0 + 35, midPoint.1 + 10)
        rightPoint = (midPoint.0 + 35, midPoint.1 - 22.5)
        let buyToSellArrow = Shape(form: Polyline(points: [leftPoint.0, leftPoint.1, midPoint.0, midPoint.1, rightPoint.0, rightPoint.1]))
        
        let sourceNodeAngle = 148.5 * Double.pi / 180
        midPoint = (WIDTH / 2 + cos(sourceNodeAngle) * SOURCE_RADIUS, HEIGHT * THREE_QUARTERS - sin(sourceNodeAngle) * SOURCE_RADIUS)
        leftPoint = (midPoint.0, midPoint.1 - 35)
        rightPoint = (midPoint.0 - 30, midPoint.1 - 25)
        let sellToSourceArrow = Shape(form: Polyline(points: [leftPoint.0, leftPoint.1, midPoint.0, midPoint.1, rightPoint.0, rightPoint.1]))
        
        // Init all UI elements
        arbitrageElements = [sourceToBuyArc, sourceToBuyArrow, buyToSellArc, buyToSellArrow, sellToSourceArc, sellToSourceArrow, sourceGroup, buyGroup, sellGroup]
        super.init(node: arbitrageElements.group(), coder: aDecoder)
    }
    
    func displayOpportunity(_ spread: WidestSpread) {
        print("Buy \(spread.buyQuantity) on \(spread.buyExchange) for \(spread.buyPrice)")
        print("Sell \(spread.sellQuantity) on \(spread.sellExchange) for \(spread.sellPrice)")
        
        var tempElements = arbitrageElements
        // Step 1
        let deposit1 = Text(text: "1.Deposit USD", font: DEFAULT_FONT, align: .mid, place: .move(dx: 0, dy: -7))
        let deposit2 = Text(text: "into \(spread.buyExchange)", font: DEFAULT_FONT, align: .mid, place: .move(dx: 0, dy: 7))
        let depositGroup = Group(contents: [deposit1, deposit2], place: .move(dx: WIDTH * 7/8 - 8, dy: HEIGHT * 0.5))
        tempElements.append(depositGroup)
        
        // Step 2
        let ask1 = Text(text: "2.\(spread.buyExchange) ask:", font: DEFAULT_FONT, align: .mid, place: .move(dx: 0, dy: -14))
        let ask2 = Text(text: "Buy \(spread.btcQuantity) BTC", font: DEFAULT_FONT, align: .mid)
        let ask3 = Text(text: "@ $\(spread.buyPrice)", font: DEFAULT_FONT, align: .mid, place: .move(dx: 0, dy: 14))
        let askGroup = Group(contents: [ask1, ask2, ask3], place: .move(dx: WIDTH * THREE_QUARTERS, dy: HEIGHT * ONE_QUARTER))
        tempElements.append(askGroup)
        
        // Step 3
        let move1 = Text(text: "3.Move BTC to \(spread.sellExchange)", font: DEFAULT_FONT, align: .mid, place: .move(dx: 0, dy: -12))
        var moveContents = [move1]
        if spread.hasWithdrawalFee {
            moveContents.append(Text(text: "(Minus \(spread.buyWithdrawalFee) withdrawal fee)", font: DEFAULT_FONT, align: .mid))
        }
        let moveGroup = Group(contents: moveContents, place: .move(dx: WIDTH / 2, dy: 25))
        tempElements.append(moveGroup)
        
        // Step 4
        let bid1 = Text(text: "4.\(spread.sellExchange) bid:", font: DEFAULT_FONT, align: .mid, place: .move(dx: 0, dy: -14))
        let bid2 = Text(text: "Sell \(spread.btcQuantity) BTC", font: DEFAULT_FONT, align: .mid)
        let bid3 = Text(text: "@ $\(spread.sellPrice)", font: DEFAULT_FONT, align: .mid, place: .move(dx: 0, dy: 14))
        let bidGroup = Group(contents: [bid1, bid2, bid3], place: .move(dx: WIDTH * ONE_QUARTER, dy: HEIGHT * ONE_QUARTER))
        tempElements.append(bidGroup)
        
        // Step 5
        let withdraw1 = Text(text: "5.Withdraw USD", font: DEFAULT_FONT, align: .mid, place: .move(dx: 0, dy: -7))
        let withdraw2 = Text(text: "from \(spread.sellExchange)", font: DEFAULT_FONT, align: .mid, place: .move(dx: 0, dy: 7))
        let withdrawGroup = Group(contents: [withdraw1, withdraw2], place: .move(dx: WIDTH * 1/8 + 8, dy: HEIGHT * 0.5))
        tempElements.append(withdrawGroup)
        
        // End result
        let arb1 = Text(text: "Theoretical profit: $\(spread.profit)", font: DEFAULT_FONT, align: .mid, place: .move(dx: 0, dy: -14))
        var contents = [arb1]
        if spread.profit.first! == "-" {
            contents.append(Text(text: "There are no profitable opportunities at the moment", font: DEFAULT_FONT, fill: Color.red, align: .mid))
        }
        let arbGroup = Group(contents: contents, place: .move(dx: WIDTH * 0.5, dy: HEIGHT * 0.925))
        tempElements.append(arbGroup)

        // Redraw diagram with new elements
        self.node = tempElements.group()
    }
}
