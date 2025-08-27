//
//  ContentView.swift
//  MenuBar
//
//  Created by Виктор Корольков on 27.08.2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var vm: TickerViewModel

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Crypto Quotes")
                    .font(.headline)
                Spacer()
                ConnectionDot(status: vm.connectionStatus)
            }
            .padding(.horizontal)

            if vm.orderedTickers.isEmpty {
                Text("Добавьте тикер (например, BTC или ETH)")
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 16)
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 10) {
                        ForEach(vm.orderedTickers) { t in
                            TickerRow(ticker: t) {
                                vm.remove(symbol: t.symbol)
                            }
                            .padding(.horizontal, 10)
                        }
                    }
                }
                .frame(maxHeight: 280)
            }

            HStack(spacing: 8) {
                TextField("BTC / ETH / UNI …", text: $vm.inputSymbol)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit { vm.addSymbol() }
                Button(action: vm.addSymbol) { Image(systemName: "plus.circle.fill") }
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
