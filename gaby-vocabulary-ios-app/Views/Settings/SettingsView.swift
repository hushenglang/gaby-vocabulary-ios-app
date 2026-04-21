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
        Section {
            ForEach(viewModel.settings.reminders) { reminder in
                reminderRow(reminder)
            }
            .onDelete { viewModel.removeReminders(at: $0) }

            Button {
                withAnimation {
                    viewModel.addReminder()
                }
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(AppTheme.primary)
                    Text("Add Reminder")
                        .foregroundStyle(AppTheme.primary)
                }
            }
        } header: {
            Text("Reminders")
        } footer: {
            if viewModel.settings.reminders.isEmpty {
                Text("Tap \"Add Reminder\" to set a daily study reminder.")
            }
        }
    }

    private func reminderRow(_ reminder: StudyReminder) -> some View {
        HStack {
            DatePicker(
                "",
                selection: Binding(
                    get: { reminder.date },
                    set: { viewModel.updateReminderTime(reminder, date: $0) }
                ),
                displayedComponents: .hourAndMinute
            )
            .labelsHidden()

            Spacer()

            Toggle("", isOn: Binding(
                get: { reminder.isEnabled },
                set: { viewModel.toggleReminder(reminder, enabled: $0) }
            ))
            .labelsHidden()
            .tint(AppTheme.primary)
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
