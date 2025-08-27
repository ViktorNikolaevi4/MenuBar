
import Foundation

final class TickerViewModel: ObservableObject {
    @Published var tickers: [String: Ticker] = [:] // key = symbol
    @Published var connectionStatus: String = ""
    @Published var inputSymbol: String = ""

    private var connectAttempt = 0

    private static let symbolsKey = "savedSymbols"


    private var symbols: [String]
    private lazy var session: URLSession = {
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        return URLSession(configuration: config)
    }()
    private var ws: URLSessionWebSocketTask?
    private var pingTimer: Timer?
    private var reconnectWorkItem: DispatchWorkItem?
    private var isManualClose = false
    private let maxHistory = 60

    init(initialSymbols: [String]) {
        // 1) грузим сохранённые тикеры, если есть
        if let saved = UserDefaults.standard.array(forKey: Self.symbolsKey) as? [String], !saved.isEmpty {
            self.symbols = saved
        } else {
            self.symbols = initialSymbols
        }
        connect()
    }

    private func saveSymbols() {
        UserDefaults.standard.set(symbols, forKey: Self.symbolsKey)
    }

    // MARK: - Public API
    var orderedTickers: [Ticker] { tickers.values.sorted { $0.symbol < $1.symbol } }

    func addSymbol() {
        let raw = inputSymbol.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard !raw.isEmpty else { return }
        let s = raw.hasSuffix("USDT") ? raw : raw + "USDT"
        guard !symbols.contains(s) else { inputSymbol = ""; return }
        symbols.append(s)
        saveSymbols()
        inputSymbol = ""
        reconnect()
    }

    func remove(symbol: String) {
        symbols.removeAll { $0 == symbol }
        tickers[symbol] = nil
        saveSymbols()
        reconnect()
    }

    // MARK: - WebSocket lifecycle
    func connect() {
        guard !symbols.isEmpty else { connectionStatus = "Add a symbol"; return }

        // 1) Список потоков
        let list = symbols.map { "\($0.lowercased())@miniTicker" }

        // 2) Перебор хостов/режимов:
        //    0: binance /stream?streams=...
        //    1: vision  /stream?streams=...
        //    2: binance /ws/<one> (если 1 тикер)
        //    3: vision  /ws/<one> (если 1 тикер)
        let mode = connectAttempt % 4
        let host = (mode == 0 || mode == 2) ? "stream.binance.com" : "data-stream.binance.vision"
        let useSingleWS = (mode >= 2) && list.count == 1

        var url: URL
        if useSingleWS {
            // одиночный поток
            url = URL(string: "wss://\(host)/ws/\(list[0])")!
        } else {
            // комбинированный поток
            let joined = list.joined(separator: "/")
            // у vision порт не обязателен, у stream.binance.com — норм и так, и без явного порта
            url = URL(string: "wss://\(host)/stream?streams=\(joined)")!
        }

        // 3) Запрос с «приятным» Origin — помогает с некоторыми прокси
        var req = URLRequest(url: url)
        req.setValue("https://binance.com", forHTTPHeaderField: "Origin")
        req.timeoutInterval = 15

        isManualClose = false
        connectionStatus = "Connecting…"

        ws?.cancel(with: .goingAway, reason: nil)
        let task = session.webSocketTask(with: req)
        ws = task
        task.resume()

        #if DEBUG
        print("[WS] URL =>", url.absoluteString, "| attempt:", connectAttempt)
        #endif

        startPing()
        receiveLoop()
        connectionStatus = "Connected"
    }


    func disconnect() {
        isManualClose = true
        stopPing()
        ws?.cancel(with: .normalClosure, reason: nil)
        ws = nil
        connectionStatus = "Disconnected"
    }

    func reconnect() {
        disconnect()
        let work = DispatchWorkItem { [weak self] in self?.connect() }
        reconnectWorkItem?.cancel()
        reconnectWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8, execute: work)
    }

    private func startPing() {
        stopPing()
        pingTimer = Timer.scheduledTimer(withTimeInterval: 20, repeats: true) { [weak self] _ in
            self?.ws?.sendPing { error in
                if let error = error { self?.handleError(error) }
            }
        }
    }

    private func stopPing() { pingTimer?.invalidate(); pingTimer = nil }

    private func receiveLoop() {
        ws?.receive { [weak self] result in
            guard let self else { return }
            switch result {
            case .failure(let error):
                self.handleError(error)
            case .success(let message):
                switch message {
                case .data(let data): self.handleMessageData(data)
                case .string(let text): self.handleMessageText(text)
                @unknown default: break
                }
                self.receiveLoop() // keep listening
            }
        }
    }

    private func handleMessageText(_ text: String) {
        guard let data = text.data(using: .utf8) else { return }
        handleMessageData(data)
    }

    private func handleMessageData(_ data: Data) {
        if let payload = try? JSONDecoder().decode(CombinedStream<MiniTicker>.self, from: data) {
            applyMiniTicker(payload.data)
        } else if let mt = try? JSONDecoder().decode(MiniTicker.self, from: data) {
            applyMiniTicker(mt)
        } else {
            // silently ignore other frames
        }
    }

    private func applyMiniTicker(_ mt: MiniTicker) {
        guard let price = Double(mt.c), let open = Double(mt.o) else { return }
        DispatchQueue.main.async {
            var t = self.tickers[mt.s] ?? Ticker(symbol: mt.s, price: price, open: open, history: [])
            t.price = price
            t.open = open
            var hist = t.history
            hist.append(price)
            if hist.count > self.maxHistory { hist.removeFirst(hist.count - self.maxHistory) }
            t.history = hist
            self.tickers[mt.s] = t
        }
    }

    private func handleError(_ error: Error) {
        connectAttempt += 1
        DispatchQueue.main.async { self.connectionStatus = "Error: \(error.localizedDescription)" }
        guard !isManualClose else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.connect()
        }
    }

}
