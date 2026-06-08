import Foundation
import SwiftData

@Model
final class SDItem {
    var id: UUID
    var title: String
    var timestamp: Date
    var value: Double

    init(id: UUID = UUID(), title: String, timestamp: Date = Date(), value: Double) {
        self.id        = id
        self.title     = title
        self.timestamp = timestamp
        self.value     = value
    }
}
