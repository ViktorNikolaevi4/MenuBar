
import Foundation

 struct CombinedStream<T: Decodable>: Decodable {
    let stream: String
    let data: T
}

 struct MiniTicker: Decodable {
    let s: String   // symbol
    let c: String   // close price
    let o: String   // open price
}
