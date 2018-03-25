import UIKit
import Macaw

class ArbitrageView: MacawView {
    private let WIDTH = 375.0
    private let HEIGHT = 400.0
    private let THREE_QUARTERS = 0.75
    private let ONE_QUARTER = 0.25
    private let RADIUS = 45.0
    
    private var arbitrageElements: [Node]
    
    required init?(coder aDecoder: NSCoder) {
        let dollarImg = Image(src: "dollar.png", place: .move(dx: -25, dy: -25))
        let sourceNode = Shape(form: Circle(cx: 0, cy: 0, r: RADIUS), fill: Color.white, stroke: Stroke(fill: Color.black, width: 2.0))
        let sourceGroup = Group(contents: [sourceNode, dollarImg], place: .move(dx: WIDTH / 2, dy: HEIGHT * THREE_QUARTERS))
        
        let bitcoinImg = Image(src: "bitcoin.png", place: .move(dx: -17.5, dy: -40))
        let buyNode = Shape(form: Circle(cx: 0, cy: 0, r: RADIUS), fill: Color.white, stroke: Stroke(fill: Color.black, width: 2.0))
        let buyGroup = Group(contents: [buyNode, bitcoinImg], place: .move(dx: WIDTH * THREE_QUARTERS, dy: HEIGHT * ONE_QUARTER))
        
        let sellNode = Shape(form: Circle(cx: 0, cy: 0, r: RADIUS), fill: Color.white, stroke: Stroke(fill: Color.black, width: 2.0))
        let sellGroup = Group(contents: [sellNode, bitcoinImg], place: .move(dx: WIDTH * ONE_QUARTER, dy: HEIGHT * ONE_QUARTER))
        
        let sourceToBuyEll = Ellipse(cx: WIDTH / 2, cy: HEIGHT * ONE_QUARTER, rx: WIDTH * ONE_QUARTER, ry: HEIGHT * 0.5)
        let sourceToBuyArc = Shape(form: sourceToBuyEll.arc(shift: 0, extent: Double.pi / 2))
        
        let buyToSellEll = Ellipse(cx: WIDTH / 2, cy: HEIGHT * ONE_QUARTER, rx: WIDTH * ONE_QUARTER, ry: 60)
        // TODO switch the sign of shift to accomodate animation
        let buyToSellArc = Shape(form: buyToSellEll.arc(shift: -Double.pi, extent: -Double.pi))
        
        let sellToSourceEll = Ellipse(cx: WIDTH / 2, cy: HEIGHT * ONE_QUARTER, rx: WIDTH * ONE_QUARTER, ry: HEIGHT * 0.5)
        let sellToSourceArc = Shape(form: sellToSourceEll.arc(shift: Double.pi / 2, extent: Double.pi / 2))
        
        arbitrageElements = [sourceToBuyArc, buyToSellArc, sellToSourceArc, sourceGroup, buyGroup, sellGroup]
        
        super.init(node: arbitrageElements.group(), coder: aDecoder)
    }
    
    func displayOpportunity(_ spread: WidestSpread) {
        print("Buy on \(spread.buyExchange) for \(spread.buyPrice)")
        print("Sell on \(spread.sellExchange) for \(spread.sellPrice)")
        
        var tempElements = arbitrageElements
        
        let moveStr = "Move BTC to \(spread.sellExchange)"
        let moveText = Text(text: moveStr, font: Font(name: "San Francisco", size: 14), align: .mid, place: .move(dx: WIDTH / 2, dy: 10))
        tempElements.append(moveText)
        
        let depositStr = "Deposit USD\ninto \(spread.buyExchange)"
        let depositText = Text(text: depositStr, font: Font(name: "San Francisco"), align: .mid, place: .move(dx: WIDTH * 7/8 - 10, dy: HEIGHT * 0.5))
        tempElements.append(depositText)
        
        let withdrawStr = "Withdraw USD\nfrom \(spread.sellExchange)"
        let withdrawText = Text(text: withdrawStr, font: Font(name: "San Francisco"), align: .mid, place: .move(dx: WIDTH * 1/8 + 10, dy: HEIGHT * 0.5))
        tempElements.append(withdrawText)

        // TODO Add to buyGroup
        let askStr = "\(spread.buyExchange) bid:\n$\(spread.buyPrice)"
        let askText = Text(text: askStr, font: Font(name: "San Francisco"), align: .mid, baseline: .mid, place: .move(dx: WIDTH * THREE_QUARTERS, dy: HEIGHT * ONE_QUARTER + 5))
        tempElements.append(askText)
        
        let bidStr = "\(spread.sellExchange) ask:\n$\(spread.sellPrice)"
        let bidText = Text(text: bidStr, font: Font(name: "San Francisco"), align: .mid, baseline: .mid, place: .move(dx: WIDTH * ONE_QUARTER, dy: HEIGHT * ONE_QUARTER + 5))
        tempElements.append(bidText)
        
        let arbStr = "Theoretical profit: $\(spread.spread)"
        let arbTxt = Text(text: arbStr, font: Font(name: "San Francisco", size: 14), align: .mid, baseline: .mid, place: .move(dx: WIDTH * 0.2, dy: HEIGHT * 0.9))
        tempElements.append(arbTxt)
        
        // Redraw diagram with new elements
        self.node = tempElements.group()
    }
}
