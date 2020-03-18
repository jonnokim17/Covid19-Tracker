//
//  MacawChartView.swift
//  Covid19 Tracker
//
//  Created by Jonathan Kim on 3/17/20.
//  Copyright © 2020 jonno. All rights reserved.
//

import Foundation
import Macaw

class MacawChartView: MacawView {
    
    static var lastFiveData = createDummyData()
    static var maxValue = 200
    static let maxValueLineHeight = 180
    static let lineWidth: Double = 275
    
    static var dataDivisor = Double(maxValue/maxValueLineHeight)
    static var adjustedData: [Double] = lastFiveData.map({ Double($0.confirmed) / dataDivisor })
    static var animations: [Animation] = []
    
    required init?(coder aDecoder: NSCoder) {
        super.init(node: MacawChartView.createChartView(), coder: aDecoder)
        backgroundColor = .clear
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        node = MacawChartView.createChartView()
        backgroundColor = .clear        
    }
    
    private static func createChartView() -> Group {
        var items: [Node] = addYAxisItems() + addXAxisItems()
        items.append(createBars())
        
        return Group(contents: items, place: .identity)
    }
    
    private static func addYAxisItems() -> [Node] {
        let maxLines = 6
//        let lineInterval = Int(maxValue/maxLines)
        let yAxisHeight: Double = 200
        let lineSpacing: Double = 30
        
        var newNodes: [Node] = []
        
        for i in 1...maxLines {
            let y = yAxisHeight - (Double(i) * lineSpacing)
            let valueLine = Line(x1: -5, y1: y, x2: lineWidth, y2: y).stroke(fill: Color.white.with(a: 0.10))
//            let valueText = Text(text: "\(i * lineInterval)", align: .max, baseline: .mid, place: .move(dx: -10, dy: y))
//            valueText.fill = Color.white
            
            newNodes.append(valueLine)
//            newNodes.append(valueText)
        }
        
        let yAxis = Line(x1: 0, y1: 0, x2: 0, y2: yAxisHeight).stroke(fill: Color.white.with(a: 0.25))
        newNodes.append(yAxis)
        
        return newNodes
    }
    
    private static func addXAxisItems() -> [Node] {
        let chartBaseY: Double = 200
        var newNodes: [Node] = []
        
        guard !adjustedData.isEmpty else { return [] }
        
        for i in 1...adjustedData.count {
            let x = (Double(i) * 50)
            let formattedDate = String(lastFiveData[i - 1].date.dropFirst(5))
            let modifiedFormattedDate = formattedDate.replace(target: "-", withString: "/")
            let valueText = Text(text: String(modifiedFormattedDate), align: .max, baseline: .mid, place: .move(dx: x, dy: chartBaseY + 15))
            valueText.fill = Color.white
            newNodes.append(valueText)
        }
        
        let xAxis = Line(x1: 0, y1: chartBaseY, x2: lineWidth, y2: chartBaseY).stroke(fill: Color.white.with(a: 0.25))
        newNodes.append(xAxis)
        
        
        return newNodes
    }
    
    private static func createBars() -> Group {
        let fill = LinearGradient(degree: 90, from: Color.aqua, to: Color.aqua.with(a: 0.33))
        let items = adjustedData.map { _ in Group() }
        
        animations = items.enumerated().map { (i: Int, item: Group) in
            item.contentsVar.animation(delay: Double(i) * 0.1) { t in
                let height = adjustedData[i] * t
                let rect = Rect(x: Double(i) * 50 + 25, y: 200 - height, w: 30, h: height)
                return [rect.fill(with: fill)]
            }
        }
        
        return items.group()
    }
    
    static func playAnimations() {
        animations.combine().play()
    }
    
    private static func createDummyData() -> [GraphData] {
        let one = GraphData(json: [
            "date": "3/12",
            "confirmed": 70
        ])
        
        let two = GraphData(json: [
            "date": "3/13",
            "confirmed": 75
        ])
        
        let three = GraphData(json: [
            "date": "3/14",
            "confirmed": 82
        ])
        
        let four = GraphData(json: [
            "date": "3/15",
            "confirmed": 114
        ])
        
        let five = GraphData(json: [
            "date": "3/16",
            "confirmed": 147
        ])
        
        return [one, two, three, four, five]
    }
}
