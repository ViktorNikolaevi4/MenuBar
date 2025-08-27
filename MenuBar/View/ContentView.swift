//
//  ContentView.swift
//  MenuBar
//
//  Created by Виктор Корольков on 27.08.2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var vm: TickerViewModel

    // Сколько строк показываем без прокрутки
    private let visibleRows = 7
    private let rowHeight: CGFloat = 60
    private let rowSpacing: CGFloat = 10

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Crypto Quotes").font(.headline)
                Spacer()
                ConnectionDot(status: vm.connectionStatus)
            }
            .padding(.horizontal)

            if vm.orderedTickers.isEmpty {
                Text("Добавьте тикер (например, BTC или ETH)")
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 16)
            } else {
                // Высота: min(кол-во, 7) * (высота строки + отступы между ними)
                let rows = min(vm.orderedTickers.count, visibleRows)
                let maxH = rowHeight * CGFloat(rows) + rowSpacing * CGFloat(max(0, rows - 1))

                ScrollView {
                    LazyVStack(alignment: .leading, spacing: rowSpacing) {
                        ForEach(vm.orderedTickers) { t in
                            TickerRow(ticker: t) {
                                vm.remove(symbol: t.symbol)
                            }
                            .padding(.horizontal, 10)
                        }
                    }
                    .padding(.vertical, 2)
                }
                .frame(maxHeight: maxH)               // «окно» на 7 строк
                .scrollIndicators(.visible)           // можно .hidden, если хотите
            }

            HStack(spacing: 8) {
                TextField("BTC / ETH / UNI …", text: $vm.inputSymbol)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit { vm.addSymbol() }
                Button(action: vm.addSymbol) {
                    Image(systemName: "plus.circle.fill")
                }
                .buttonStyle(.borderless)
            }
            .padding(.horizontal)

            HStack {
                Text(vm.connectionStatus)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Spacer()
                Button("Reconnect") { vm.reconnect() }
                    .buttonStyle(.link)
            }
            .padding([.horizontal, .bottom])
        }
        .padding(.top, 10)
        .frame(minWidth: 300)
    }
}
