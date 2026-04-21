import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = SettingsViewModel()
    @State private var showResetConfirmation = false

    var body: some View {
        NavigationStack {
            Form {
                studyPlanSection
                remindersSection
                statisticsSection
                dataSection
            }
            .navigationTitle("Settings")
        }
        .onAppear {
            viewModel.loadStats(context: modelContext)
        }
    }

    private var studyPlanSection: some View {
        Section("Study Plan") {
            Stepper(
                "Daily New Words: \(viewModel.settings.dailyNewWords)",
                value: Binding(
                    get: { viewModel.settings.dailyNewWords },
                    set: { viewModel.settings.dailyNewWords = $0 }
                ),
                in: 1...50
            )
        }
    }

    private var remindersSection: some View {
        Section("Reminders") {
            Toggle("Study Reminder", isOn: Binding(
                get: { viewModel.settings.reminderEnabled },
                set: { viewModel.toggleReminder(enabled: $0) }
            ))
            .tint(AppTheme.primary)

            if viewModel.settings.reminderEnabled {
                DatePicker(
                    "Reminder Time",
                    selection: Binding(
                        get: { viewModel.settings.reminderDate },
                        set: {
                            viewModel.settings.reminderDate = $0
                            viewModel.updateReminderTime()
                        }
                    ),
                    displayedComponents: .hourAndMinute
                )
            }
        }
    }

    private var statisticsSection: some View {
        Section("Statistics") {
            HStack(spacing: AppTheme.spacing8) {
                StatCardView(
                    value: viewModel.totalWords,
                    label: "Total\nWords",
                    color: AppTheme.primary
                )
                StatCardView(
                    value: viewModel.masteredWords,
                    label: "Mastered",
                    color: AppTheme.success
                )
                StatCardView(
                    value: viewModel.dueToday,
                    label: "Due\nToday",
                    color: AppTheme.warning
                )
            }
            .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
            .listRowBackground(Color.clear)
        }
    }

    private var dataSection: some View {
        Section("Data") {
            Button(role: .destructive) {
                showResetConfirmation = true
            } label: {
                HStack {
                    Image(systemName: "exclamationmark.triangle")
                    Text("Reset All Progress")
                }
            }
            .alert("Reset Progress?", isPresented: $showResetConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    viewModel.resetProgress(context: modelContext)
                }
            } message: {
                Text("This will reset all review progress. Your words will be kept.")
            }
        }
    }
}
