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

extension Array where Element: Loo {
    func filterByDate(_ date: Date = Date()) -> [Loo] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: DateComponents(day: 1, second: -1), to: startOfDay) else {
            return self
        }
        return self.filter { item in
            (startOfDay ... endOfDay).contains(item.timestamp)
        }
    }
    
    func totalAmount() -> Int {
        self.reduce(0) { $0 + $1.amount }
    }
    
    func lastWeekAmount() -> [Date:Int] {
        var total: [Date:Int] = [:]
        var current: Date = Date()
        
        for _ in 1...7 {
            guard let newDay = Calendar.current.date(byAdding: DateComponents(day: -1), to: current) else {return [:]}
            current = newDay
            total[current] = self.filterByDate(current).totalAmount()
        }
        
        return total
    }
}
