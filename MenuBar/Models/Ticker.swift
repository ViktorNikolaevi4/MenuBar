

import Foundation

struct Ticker: Identifiable, Equatable {
    var id: String { symbol }
    let symbol: String // e.g., "BTCUSDT"
    var price: Double
    var open: Double
    var history: [Double] = [] // last N prices for sparkline

    var changePercent: Double {
        guard open != 0 else { return 0 }
        return (price - open) / open * 100
    }

    var base: String { String(symbol.prefix { $0.isLetter }.uppercased()) }
}
