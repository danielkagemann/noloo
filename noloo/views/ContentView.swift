import SwiftData
import SwiftUI

struct ContentView: View {
    /// env
    @Environment(\.modelContext) private var modelContext
    @Environment(\.undoManager) private var undoManager

    /// query
    @Query(sort: [SortDescriptor<Loo>(\.timestamp, order: .reverse)]) private var items: [Loo]

    /// app storage for daily goal (in ml)
    @AppStorage("DailyLoo") private var dailyLoo: Int = 2000

    @State private var bannerMessage: String? = nil
    @State private var bannerShowsUndo: Bool = false
    @State private var lastDeleted: Loo? = nil

    /// sum of today's intake
    private var todayTotal: Int {
        filteredForToday.reduce(0) { $0 + $1.amount }
    }

    /// filter for the current day
    var filteredForToday: [Loo] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        guard let endOfDay = calendar.date(byAdding: DateComponents(day: 1, second: -1), to: startOfDay) else {
            return items
        }
        return items.filter { item in
            (startOfDay ... endOfDay).contains(item.timestamp)
        }
    }

    func ActionButtons() -> some View {
        HStack(spacing: 12) {
            ForEach([20, 50, 100, 250], id: \.self) { value in
                Button("+\(value)ml") { addItem(value) }
                    .buttonStyle(.glassProminent)
                    .tint(.accent)
            }
        }
    }

    func Today() -> some View {
        // Progress header for today's goal
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Today")
                    .font(.headline)
                Spacer()
                Text("\(todayTotal) / \(dailyLoo) ml")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            ProgressView(value: min(Double(todayTotal), Double(dailyLoo)), total: Double(max(dailyLoo, 1)))
                .tint(.accent)
            HStack {
                Image(systemName: todayTotal >= dailyLoo ? "checkmark.seal.fill" : "drop.fill")
                    .foregroundStyle(todayTotal >= dailyLoo ? .green : .accent)
                Text(todayTotal >= dailyLoo ? "Goal reached" : "Keep going")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Stepper("Goal: \(dailyLoo) ml", value: $dailyLoo, in: 250 ... 10000, step: 50)
                    .labelsHidden()
            }
        }
        .padding(.vertical, 8)
    }

    @ViewBuilder
    func Notification() -> some View {
        if let message = bannerMessage {
            HStack(spacing: 12) {
                Image(systemName: bannerShowsUndo ? "trash" : "checkmark.circle")
                Text(message)
                    .font(.subheadline)
                    .lineLimit(2)
                Spacer()
                if bannerShowsUndo {
                    Button("Undo") {
                        if let item = lastDeleted {
                            modelContext.insert(item)
                        }
                        bannerMessage = nil
                        bannerShowsUndo = false
                        lastDeleted = nil
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.accent)
                }
            }
            .foregroundStyle(.white)
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background(bannerShowsUndo ? .red : .green)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .padding(.horizontal)
            .padding(.top)
            .transition(.move(edge: .top).combined(with: .opacity))
            .animation(.spring(duration: 0.35), value: bannerMessage)
        }
    }

    func LooItemList() -> some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 90, maximum: 140), spacing: 12),
            ], spacing: 12) {
                ForEach(filteredForToday) { item in
                    LooItemView(item: item) {
                        deleteItemWithUndo(item)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                Today()
                    .padding(.horizontal)
                LooItemList()
            }
            ActionButtons()
            Notification()
        }
    }

    private func addItem(_ value: Int) {
        let new = Loo(amount: value)
        modelContext.insert(new)
        showBanner(message: "+\(value) ml added", showsUndo: false)
    }

    private func deleteItems(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(items[index])
        }
    }

    private func deleteItemWithUndo(_ item: Loo) {
        // Cache for manual undo if needed
        lastDeleted = item
        // Register undo with system undo manager when available
        undoManager?.registerUndo(withTarget: modelContext) { ctx in
            ctx.insert(item)
        }
        undoManager?.setActionName("Delete Loo")
        modelContext.delete(item)
        showBanner(message: "Deleted \"\(item.amount) ml\"", showsUndo: true)
    }

    private func showBanner(message: String, showsUndo: Bool) {
        bannerMessage = message
        bannerShowsUndo = showsUndo

        // Auto-dismiss logic
        let currentMessage = message
        let delay: TimeInterval = showsUndo ? 4.0 : 2.0
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            if bannerMessage == currentMessage {
                // Only clear if the same message is still shown
                bannerMessage = nil
                bannerShowsUndo = false
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Loo.self)
}
