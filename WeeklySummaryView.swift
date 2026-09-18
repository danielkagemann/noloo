import SwiftUI
import SwiftData

struct WeeklySummaryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor<Loo>(\.timestamp, order: .reverse)]) private var items: [Loo]

    let goalML: Int

    private var days: [Date] {
        let cal = Calendar.current
        let start = cal.startOfDay(for: Date())
        return (0..<7).compactMap { cal.date(byAdding: .day, value: -$0, to: start) }
    }

    private func key(for date: Date) -> String {
        let df = DateFormatter()
        df.calendar = .current
        df.locale = .current
        df.dateFormat = "EEE, MMM d"
        return df.string(from: date)
    }

    private func total(for day: Date) -> Int {
        let cal = Calendar.current
        let start = cal.startOfDay(for: day)
        guard let end = cal.date(byAdding: DateComponents(day: 1, second: -1), to: start) else { return 0 }
        return items.filter { (start...end).contains($0.timestamp) }.reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        List {
            ForEach(days, id: \.self) { day in
                let total = total(for: day)
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(key(for: day))
                        Spacer()
                        Text("\(total) / \(goalML) ml")
                            .foregroundStyle(.secondary)
                    }
                    ProgressView(value: min(Double(total), Double(goalML)), total: Double(max(goalML, 1)))
                        .tint(.accent)
                }
                .padding(.vertical, 6)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Weekly Summary")
    }
}

#Preview {
    WeeklySummaryView(goalML: 2000)
        .modelContainer(for: Loo.self)
}
