import Foundation
import SwiftData

@Model
final class Loo {
    var id: UUID
    var timestamp: Date
    var amount: Int

    init(id: UUID = UUID(), timestamp: Date = Date(), amount: Int) {
        self.id = id
        self.timestamp = timestamp
        self.amount = amount
    }
}
