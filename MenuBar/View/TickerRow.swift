

import Foundation
import SwiftUI

struct TickerRow: View {
    let ticker: Ticker
    var onRemove: () -> Void

    private let priceFormatter: NumberFormatter = {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.maximumFractionDigits = 2
        return nf
    }()

    var body: some View {
        HStack(spacing: 12) {
            // 1) Тикер
            VStack(alignment: .leading, spacing: 2) {
                Text(ticker.base).font(.headline)
                Text(ticker.symbol.suffix(4)) // USDT
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // 2) График
            Sparkline(values: ticker.history)
                .frame(height: 28)
                .frame(maxWidth: .infinity)

            // 3) Цена + изменение
            VStack(alignment: .trailing, spacing: 4) {
                Text(priceFormatter.string(from: NSNumber(value: ticker.price)) ?? String(format: "%.2f", ticker.price))
                    .font(.title3.weight(.semibold))
                ChangePill(percent: ticker.changePercent)
            }

            Button(role: .destructive, action: onRemove) {
                Image(systemName: "minus.circle")
            }
            .buttonStyle(.plain)
        }
        .padding(10)
        .frame(height: 60) // фиксируем высоту строки для расчёта области видимости
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

