import Foundation
import SwiftUI

struct Sparkline: View {
    let values: [Double]

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let vals = values
            if let minV = vals.min(), let maxV = vals.max(), maxV > minV, vals.count > 1 {
                let scale = maxV - minV
                let step = w / CGFloat(vals.count - 1)
                Path { p in
                    for (i, v) in vals.enumerated() {
                        let x = CGFloat(i) * step
                        let y = h - (CGFloat((v - minV) / scale) * h)
                        if i == 0 { p.move(to: CGPoint(x: x, y: y)) } else { p.addLine(to: CGPoint(x: x, y: y)) }
                    }
                }
                .stroke(Color.yellow, lineWidth: 2)
            } else {
                // placeholder line
                Path { p in
                    p.move(to: CGPoint(x: 0, y: h * 0.6))
                    p.addLine(to: CGPoint(x: w, y: h * 0.4))
                }
                .stroke(.secondary, style: StrokeStyle(lineWidth: 1, dash: [3,3]))
            }
        }
    }
}
