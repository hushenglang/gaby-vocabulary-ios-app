import SwiftUI
import SwiftData

struct AddWordView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var english: String = ""
    @State private var chinese: String = ""
    @State private var showDuplicateAlert = false

    var onSaved: () -> Void

    private var canSave: Bool {
        !english.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !chinese.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("English word or phrase", text: $english)
                        .autocorrectionDisabled()
                } header: {
                    Text("English")
                }

                Section {
                    TextField("Chinese translation", text: $chinese)
                } header: {
                    Text("Chinese")
                }
            }
            .navigationTitle("Add Word")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveWord() }
                        .disabled(!canSave)
                }
            }
            .alert("Duplicate Word", isPresented: $showDuplicateAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("\"\(english.trimmingCharacters(in: .whitespacesAndNewlines))\" already exists.")
            }
        }
    }

    private func saveWord() {
        let vm = WordListViewModel()
        do {
            let success = try vm.addWord(english: english, chinese: chinese, context: modelContext)
            if success {
                onSaved()
                dismiss()
            } else {
                showDuplicateAlert = true
            }
        } catch {
            showDuplicateAlert = true
        }
    }
}
