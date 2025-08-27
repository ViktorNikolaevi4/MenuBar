

import Foundation
import SwiftUI

struct ChangePill: View {
    let percent: Double
    var body: some View {
        let up = percent >= 0
        Text(String(format: "%+.2f%%", percent))
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 8).padding(.vertical, 4)
            .background(up ? Color.green : Color.red, in: Capsule())
    }
}
