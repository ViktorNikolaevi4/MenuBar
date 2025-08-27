import SwiftUI

@main
struct CryptoMenuBarApp: App {
    @StateObject private var vm = TickerViewModel(
        initialSymbols: ["BTCUSDT"]
    )

    var body: some Scene {
        MenuBarExtra("Crypto", systemImage: "bitcoinsign.circle") {
            ContentView()
                .environmentObject(vm)
                .frame(width: 320)
        }
        .menuBarExtraStyle(.window)
    }
}
