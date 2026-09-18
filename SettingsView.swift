import SwiftUI

struct SettingsView: View {
    @Binding var dailyGoalML: Int
    @Binding var incrementML: Int

    var body: some View {
        Form {
            Section("Daily Goal") {
                Stepper(value: $dailyGoalML, in: 250...10000, step: 50) {
                    HStack {
                        Text("Goal")
                        Spacer()
                        Text("\(dailyGoalML) ml")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            Section("Quick-add Increment") {
                Stepper(value: $incrementML, in: 10...1000, step: 10) {
                    HStack {
                        Text("Increment")
                        Spacer()
                        Text("\(incrementML) ml")
                            .foregroundStyle(.secondary)
                    }
                }
                Text("Quick-add buttons are multiples of this increment.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    SettingsView(dailyGoalML: .constant(2000), incrementML: .constant(50))
}
