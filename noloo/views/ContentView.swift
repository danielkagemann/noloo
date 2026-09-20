import SwiftData
import SwiftUI

struct ContentView: View {
    /// env
    @Environment(\.modelContext) private var modelContext
    @Environment(\.undoManager) private var undoManager
    @Environment(\.scenePhase) private var scenePhase

    /// query
    @Query(sort: [SortDescriptor<Loo>(\.timestamp, order: .reverse)]) private var items: [Loo]

    /// app storage for daily goal (in ml)
    @AppStorage("DailyLoo") private var dailyLoo: Int = 2000
    @AppStorage("notification") private var remindersEnabled: Bool = false

    /// states
    @State private var bannerMessage: String? = nil
    @State private var bannerShowsUndo: Bool = false
    @State private var lastDeleted: Loo? = nil
    @State private var showAllItems: Bool = false

    /// filter for the current day
    var filteredForToday: [Loo] {
        return items.filterByDate()
    }

    /// sum of today's intake
    private var todayTotal: Int {
        filteredForToday.totalAmount()
    }

    func ActionButtons() -> some View {
        VStack {
            Divider().padding(.bottom, 16).animFadeIn(delay:0.5)
            HStack(spacing: 12) {
                ForEach([20, 50, 100], id: \.self, content: { (value: Int) in
                    Button("+\(value)ml") { addItem(value) }
                        .buttonStyle(.glass)
                        .tint(.accent)
                        .animSlideUp(value: 50, delay: Double(value / 1000))
                        .flyingSymbol {
                            Image(systemName: "drop.fill")
                                .font(.title3)
                                .foregroundStyle(.blue)
                        }
                })
                Button("+250ml") { addItem(250) }
                    .buttonStyle(.glassProminent)
                    .tint(.accent)
                    .animSlideUp(value: 10, delay: 0.25)
            }
        }
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
                    Button("Rückgängig") {
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
            .animFlipY(from: 0, to: 1)
        }
    }

    func LooItemList() -> some View {
        VStack(alignment: .leading) {
            Text("Letzte Einträge")
                .font(.title2)
                .alignLeft()

            HStack {
                ForEach(filteredForToday.prefix(3)) { item in
                    LooItemView(item: item) {
                        deleteItemWithUndo(item)
                    }
                }

                if filteredForToday.count > 3 {
                    Button(action: {
                        showAllItems.toggle()
                    }, label: {
                        VStack {
                            Text("+\(filteredForToday.count - 3)")
                            Text("weitere")
                        }
                    })
                }
            }
            Spacer()
        }
        .padding(.top, 16)
        .padding(.horizontal)
    }

    var whichGlas: String {
        let percent = (todayTotal * 100) / dailyLoo
        if percent < 25 {
            return "glas-0"
        }
        if percent < 50 {
            return "glas-25"
        }
        if percent < 75 {
            return "glas-50"
        }
        if percent < 100 {
            return "glas-75"
        }
        return "glas-100"
    }

    var body: some View {
        if todayTotal == 0 {
            VStack {
                Spacer()
                EmptyLooView()
                VStack(spacing: 8) {
                    ForEach([20, 50, 100, 250], id: \.self, content: { (value: Int) in
                        Button("+\(value)ml") { addItem(value) }
                            .buttonStyle(.glassProminent)
                            .tint(.accent)
                            .animSlideUp(value: 50, delay: Double(value / 1000))
                    })
                }
                Spacer()
            }
        } else {
            ZStack(alignment: .top) {
                VStack(spacing: 32) {
                    LastDaysView()
                    HStack {
                        Image(whichGlas)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 200)
                        Today(value: todayTotal)
                    }
                    LooItemList()
                    ActionButtons()
                }
                if !showAllItems {
                    Notification()
                }
            }
            .sheet(isPresented: $showAllItems) {
                VStack(alignment: .leading) {
                    Text("Alle heutigen Einträge")
                        .font(.title2)

                    Text("Tippe auf einen Eintrag um ihn zu löschen")

                    ScrollView {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 12) {
                            ForEach(filteredForToday) { item in
                                LooItemView(item: item) {
                                    deleteItemWithUndo(item)
                                }
                            }
                        }
                        .padding(.top, 4)
                    }
                    Notification()
                }
                .padding(.vertical, 32)
                .padding(.horizontal, 16)
            }
            .onChange(of: scenePhase) { _, phase in
                guard phase == .active else { return }

                updateNotifications()
            }
        }
    }
    
    private func updateNotifications() {
        if remindersEnabled {
            Task {
                do {
                    try await NotificationManager.shared.reschedule(
                        today: HydrationSnapshot(
                            consumedML: todayTotal,
                            goalML: dailyLoo
                        ),
                        tomorrowGoalML: dailyLoo
                    )
                } catch {
                    print("Unable to update notifications: \(error)")
                }
            }
        }
    }

    private func addItem(_ value: Int) {
        let new = Loo(amount: value)
        modelContext.insert(new)
        showBanner(message: "+\(value) ml hinzugefügt", showsUndo: false)

        updateNotifications()
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
        showBanner(message: "Entferne \"\(item.amount) ml\"", showsUndo: true)
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
