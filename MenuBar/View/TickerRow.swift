

import Foundation
import SwiftUI


struct TickerRow: View {
    let ticker: Ticker
    var onRemove: () -> Void

    private var priceFormatter: NumberFormatter { let nf = NumberFormatter(); nf.numberStyle = .decimal; nf.maximumFractionDigits = 2; return nf }

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(ticker.base)
                        .font(.headline)
                    Text(ticker.symbol.suffix(4)) // USDT
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Text(priceFormatter.string(from: NSNumber(value: ticker.price)) ?? String(format: "%.2f", ticker.price))
                    .font(.title3.weight(.semibold))
            }
            Spacer(minLength: 12)
            Sparkline(values: ticker.history)
                .frame(width: 86, height: 28)
                .padding(.vertical, 2)
            ChangePill(percent: ticker.changePercent)
            Button(role: .destructive, action: onRemove) { Image(systemName: "minus.circle") }
                .buttonStyle(.plain)
                .padding(.leading, 2)
        }
        .padding(10)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
