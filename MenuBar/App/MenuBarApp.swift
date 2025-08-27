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
                .frame(minWidth: 380) // желаемая ширина контента
        }
        .menuBarExtraStyle(.window)
        .defaultSize(width: 480, height: 600)   // стартовый размер окна
        .windowResizability(.contentSize)       // можно .automatic, чтобы тянуть вручную
    }
}
