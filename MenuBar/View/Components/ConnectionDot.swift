import Foundation
import SwiftUI

struct ConnectionDot: View {
    let status: String
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(status.hasPrefix("Connected") ? Color.green : (status.hasPrefix("Connecting") ? Color.orange : Color.gray))
                .frame(width: 8, height: 8)
            Text(status).font(.caption).foregroundStyle(.secondary)
        }
    }
}
